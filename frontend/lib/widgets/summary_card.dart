import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SummaryCard extends StatelessWidget {
  final Map<String, double> summary;

  const SummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildRow('Thu nhập', summary['income']!, Colors.green, formatter),
            const SizedBox(height: 12),
            _buildRow('Chi tiêu', summary['expense']!, Colors.red, formatter),
            const Divider(height: 24),
            _buildRow('Số dư', summary['balance']!, Colors.blue, formatter,
                isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
      String label, double amount, Color color, NumberFormat formatter,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          formatter.format(amount),
          style: TextStyle(
            fontSize: 16,
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}