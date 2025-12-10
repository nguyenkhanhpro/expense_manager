import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import 'add_transaction_screen.dart';

class TransactionDetailScreen extends StatefulWidget {
  final Transaction transaction;
  final Category? category;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
    this.category,
  });

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final fmtMoney = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final fmtDate = DateFormat('dd/MM/yyyy HH:mm');
    final t = widget.transaction;
    final isIncome = t.type == 'income';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết giao dịch'),
        backgroundColor: isIncome ? Colors.green : Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final navigator = Navigator.of(context);
              await navigator.push(
                MaterialPageRoute(
                  builder: (_) => AddTransactionScreen(
                    type: t.type,
                    transaction: t,
                  ),
                ),
              );
              if (!mounted) return;
              navigator.pop(true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isDeleting ? null : _confirmDelete,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor:
                      isIncome ? Colors.green.shade100 : Colors.red.shade100,
                  child: Text(widget.category?.icon ?? '💰',
                      style: const TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.category?.name ?? 'Không xác định',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      fmtDate.format(t.date),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              fmtMoney.format(t.amount),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isIncome ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ghi chú',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(t.note.isEmpty ? '—' : t.note),
            const Spacer(),
            if (_isDeleting) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
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
    if (ok != true) return;
    await _delete();
  }

  Future<void> _delete() async {
    try {
      setState(() => _isDeleting = true);
      await _apiService.deleteTransaction(widget.transaction.id!);
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa giao dịch')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xóa: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }
}

