import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/category.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final Category? category;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const TransactionItem({
    super.key,
    required this.transaction,
    this.category,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minLeadingWidth: 0,
        isThreeLine: true,
        minVerticalPadding: 10,
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: transaction.type == 'income'
              ? Colors.green.shade100
              : Colors.red.shade100,
          child: Text(
            category?.icon ?? '💰',
            style: const TextStyle(fontSize: 24),
          ),
        ),
        title: Text(category?.name ?? 'Unknown'),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transaction.note.isNotEmpty) Text(transaction.note),
            Text(
              dateFormatter.format(transaction.date),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatter.format(transaction.amount),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color:
                    transaction.type == 'income' ? Colors.green : Colors.red,
              ),
            ),
            if (onEdit != null || onDelete != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: SizedBox(
                  height: 28,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(minWidth: 32, minHeight: 32),
                        icon: const Icon(Icons.edit, size: 18),
                        tooltip: 'Sửa',
                        onPressed: onEdit,
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(minWidth: 32, minHeight: 32),
                        icon: const Icon(Icons.delete, size: 18),
                        tooltip: 'Xóa',
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}