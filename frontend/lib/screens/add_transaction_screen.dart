// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/category.dart';
import '../models/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  final String type;
  final Transaction? transaction;

  const AddTransactionScreen({
    super.key,
    required this.type,
    this.transaction,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _newCategoryNameController = TextEditingController();
  final _newCategoryIconController = TextEditingController(text: '📝');
  Category? _categoryToDelete;

  List<Category> _categories = [];
  Category? _selectedCategory;
  bool _isLoading = true;
  bool _isSaving = false;
  late final String _type;

  @override
  void initState() {
    super.initState();
    _type = widget.transaction?.type ?? widget.type;
    if (widget.transaction != null) {
      _amountController.text = widget.transaction!.amount.toString();
      _noteController.text = widget.transaction!.note;
    }
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _apiService.getCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories.where((c) => c.type == _type).toList();
        if (widget.transaction != null) {
          _selectedCategory = _categories
              .firstWhere((c) => c.id == widget.transaction!.categoryId);
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải danh mục: $e')),
        );
      }
    }
  }

  Future<void> _saveTransaction() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate() || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    try {
      setState(() => _isSaving = true);
      final transaction = Transaction(
        id: widget.transaction?.id,
        amount: double.parse(_amountController.text),
        categoryId: _selectedCategory!.id!,
        note: _noteController.text,
        date: widget.transaction?.date ?? DateTime.now(),
        type: _type,
      );

      if (widget.transaction == null) {
        await _apiService.addTransaction(transaction);
      } else {
        await _apiService.updateTransaction(transaction);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.transaction == null
                ? 'Đã lưu thành công!'
                : 'Đã cập nhật thành công!'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _showAddCategoryDialog() async {
    _newCategoryNameController.clear();
    _newCategoryIconController.text = '📝';
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Thêm danh mục mới'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _newCategoryNameController,
                  decoration: const InputDecoration(labelText: 'Tên danh mục'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Nhập tên danh mục' : null,
                ),
                TextFormField(
                  controller: _newCategoryIconController,
                  decoration: const InputDecoration(labelText: 'Biểu tượng'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                try {
                  final category = Category(
                    name: _newCategoryNameController.text,
                    type: _type,
                    icon: _newCategoryIconController.text.isEmpty
                        ? '📝'
                        : _newCategoryIconController.text,
                  );
                  await _apiService.addCategory(category);
                  if (!mounted) return;
                  Navigator.pop(dialogContext);
                  await _loadCategories();
                  if (!mounted) return;
                  setState(() {
                    _selectedCategory = _categories.last;
                  });
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi thêm danh mục: $e')),
                  );
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteCategoryDialog() async {
    _categoryToDelete = null;
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (innerContext, setDialogState) {
            return AlertDialog(
              title: const Text('Xóa danh mục'),
              content: SizedBox(
                width: double.maxFinite,
                child: _categories.isEmpty
                    ? const Text('Không có danh mục để xóa.')
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _categories.length,
                        itemBuilder: (_, index) {
                          final c = _categories[index];
                          return ListTile(
                            dense: true,
                            leading: Radio<Category>(
                              value: c,
                              groupValue: _categoryToDelete,
                              onChanged: (val) {
                                setDialogState(() {
                                  _categoryToDelete = val;
                                });
                              },
                            ),
                            title: Text('${c.icon}  ${c.name}'),
                            onTap: () {
                              setDialogState(() {
                                _categoryToDelete = c;
                              });
                            },
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_categoryToDelete == null) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Chọn danh mục để xóa')),
                      );
                      return;
                    }
                    try {
                      await _apiService.deleteCategory(_categoryToDelete!.id!);
                      if (!mounted) return;
                      Navigator.pop(dialogContext);
                      await _loadCategories();
                      if (!mounted) return;
                      if (_selectedCategory?.id == _categoryToDelete!.id) {
                        setState(() => _selectedCategory = null);
                      }
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi xóa danh mục: $e')),
                      );
                    }
                  },
                  child: const Text('Xóa'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = _type == 'income';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction == null
            ? (isIncome ? 'Thêm Thu Nhập' : 'Thêm Chi Tiêu')
            : (isIncome ? 'Sửa Thu Nhập' : 'Sửa Chi Tiêu')),
        backgroundColor: isIncome ? Colors.green : Colors.red,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Số tiền',
                        prefixText: '₫ ',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập số tiền';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Số tiền không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Category>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Danh mục',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Row(
                            children: [
                              Text(category.icon,
                                  style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Text(category.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategory = value);
                      },
                      validator: (value) =>
                          value == null ? 'Vui lòng chọn danh mục' : null,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        spacing: 8,
                        children: [
                          TextButton.icon(
                            onPressed: _showAddCategoryDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Thêm danh mục'),
                          ),
                          if (_categories.isNotEmpty)
                            TextButton.icon(
                              onPressed: _showDeleteCategoryDialog,
                              icon: const Icon(Icons.delete),
                              label: const Text('Xóa danh mục'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Ghi chú',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isIncome ? Colors.green : Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        widget.transaction == null ? 'Lưu' : 'Cập nhật',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _newCategoryNameController.dispose();
    _newCategoryIconController.dispose();
    super.dispose();
  }
}