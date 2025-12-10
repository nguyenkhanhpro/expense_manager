import 'package:flutter/material.dart';

/// Hiển thị chia quỹ đơn giản dựa trên thu nhập: 50/30/20.
class FundSplitCard extends StatelessWidget {
  final Map<String, double> summary;

  const FundSplitCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final income = summary['income'] ?? 0;
    final expense = summary['expense'] ?? 0;
    final balance = summary['balance'] ?? 0;

    // Chia quỹ: 50% nhu cầu, 30% mong muốn, 20% tiết kiệm.
    final need = income * 0.5;
    final want = income * 0.3;
    final save = income * 0.2;

    String fmt(double v) => v.toStringAsFixed(0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: Colors.teal),
                const SizedBox(width: 8),
                const Text(
                  'Chia quỹ gợi ý (50/30/20)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  'Dư: ${fmt(balance)}',
                  style: TextStyle(
                    color: balance >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _row('Nhu cầu (50%)', need, expense <= need),
            const SizedBox(height: 8),
            _row('Mong muốn (30%)', want, expense <= need + want),
            const SizedBox(height: 8),
            _row('Tiết kiệm (20%)', save, balance >= save * 0.2),
          ],
        ),
      ),
    );
  }

  Widget _row(String title, double amount, bool ok) {
    return Row(
      children: [
        Expanded(child: Text(title)),
        Text(
          amount.toStringAsFixed(0),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: ok ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}

