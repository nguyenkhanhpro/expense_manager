import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../widgets/transaction_item.dart';
import 'add_transaction_screen.dart';
import 'transaction_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  final ApiService apiService;

  HistoryScreen({super.key, ApiService? apiService})
      : apiService = apiService ?? ApiService();

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final ApiService _apiService;
  List<Transaction> _transactions = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  String _typeFilter = 'all'; // all | income | expense
  String _sortOrder = 'desc'; // desc | asc
  String _monthFilter = 'all'; // all or yyyy-MM
  String _searchQuery = '';
  late final TextEditingController _searchController;
  final DateFormat _monthFormatter = DateFormat('MM/yyyy');

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService;
    _searchController = TextEditingController();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final transactions = await _apiService.getTransactions();
      final categories = await _apiService.getCategories();
      setState(() {
        _transactions = transactions;
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Category? _getCategoryById(int id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Transaction> _filteredAndSorted() {
    final filtered = _transactions.where((transaction) {
      if (_typeFilter != 'all' && transaction.type != _typeFilter) return false;
      if (_monthFilter != 'all') {
        final key =
            '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}';
        if (key != _monthFilter) return false;
      }
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final cat = _getCategoryById(transaction.categoryId);
      return transaction.note.toLowerCase().contains(query) ||
          (cat?.name.toLowerCase().contains(query) ?? false);
    }).toList();

    filtered.sort((a, b) =>
        _sortOrder == 'desc' ? b.date.compareTo(a.date) : a.date.compareTo(b.date));
    return filtered;
  }

  List<String> _monthOptions() {
    final set = <String>{};
    for (final t in _transactions) {
      set.add('${t.date.year}-${t.date.month.toString().padLeft(2, '0')}');
    }
    final list = set.toList()..sort((a, b) => b.compareTo(a));
    return list;
  }

  String _monthLabel(String key) {
    if (key == 'all') return 'Tất cả';
    final parts = key.split('-');
    if (parts.length != 2) return key;
    final year = int.tryParse(parts[0]) ?? 0;
    final month = int.tryParse(parts[1]) ?? 1;
    return _monthFormatter.format(DateTime(year, month));
  }

  Future<void> _deleteTransaction(Transaction transaction) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa giao dịch'),
        content: const Text('Bạn có chắc muốn xóa giao dịch này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _apiService.deleteTransaction(transaction.id!);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa giao dịch')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xóa: $e')),
        );
      }
    }
  }

  Future<void> _editTransaction(Transaction transaction) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
          type: transaction.type,
          transaction: transaction,
        ),
      ),
    );
    await _loadData();
  }

  Future<void> _showDetail(Transaction transaction, Category? category) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionDetailScreen(
          transaction: transaction,
          category: category,
        ),
      ),
    );
    if (changed == true) {
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredAndSorted();
    final months = _monthOptions();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Sử Giao Dịch'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilters(months),
                Expanded(child: _buildTransactionList(filtered)),
              ],
            ),
    );
  }

  Widget _buildFilters(List<String> months) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: const Key('searchField'),
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Tìm kiếm (ghi chú / danh mục)',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Flexible(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  key: const Key('typeFilterDropdown'),
                  // ignore: deprecated_member_use
                  value: _typeFilter,
                  decoration: const InputDecoration(
                    labelText: 'Loại giao dịch',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text('Tất cả'),
                    ),
                    DropdownMenuItem(
                      value: 'income',
                      child: Text('Thu'),
                    ),
                    DropdownMenuItem(
                      value: 'expense',
                      child: Text('Chi'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _typeFilter = value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  key: const Key('sortOrderDropdown'),
                  // ignore: deprecated_member_use
                  value: _sortOrder,
                  decoration: const InputDecoration(
                    labelText: 'Sắp xếp',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: 'desc',
                      child: Text('Mới → Cũ', overflow: TextOverflow.ellipsis),
                    ),
                    DropdownMenuItem(
                      value: 'asc',
                      child: Text('Cũ → Mới', overflow: TextOverflow.ellipsis),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _sortOrder = value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  key: const Key('monthFilterDropdown'),
                  // ignore: deprecated_member_use
                  value: _monthFilter,
                  decoration: const InputDecoration(
                    labelText: 'Tháng',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem(
                      value: 'all',
                      child: Text('Tất cả'),
                    ),
                    ...months.map(
                      (m) => DropdownMenuItem(
                        value: m,
                        child: Text(_monthLabel(m), overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _monthFilter = value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                key: const Key('clearFilterButton'),
                onPressed: () {
                  setState(() {
                    _typeFilter = 'all';
                    _sortOrder = 'desc';
                    _monthFilter = 'all';
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('Xóa lọc'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có giao dịch nào',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          final category = _getCategoryById(transaction.categoryId);
          return TransactionItem(
            transaction: transaction,
            category: category,
            onEdit: () => _editTransaction(transaction),
            onDelete: () => _deleteTransaction(transaction),
            onTap: () => _showDetail(transaction, category),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}