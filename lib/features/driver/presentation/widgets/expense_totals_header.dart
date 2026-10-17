import 'package:flutter/material.dart';

import '../../../../shared/models/driver_expense.dart';

/// This month's spending, split by category. Categories with nothing in them
/// are left out so the strip stays readable, but the overall total is always
/// shown — including zero, which is itself worth knowing.
class ExpenseTotalsHeader extends StatelessWidget {
  const ExpenseTotalsHeader({super.key, required this.summary});

  final ExpenseSummary summary;

  @override
  Widget build(BuildContext context) {
    final month = summary.month;
    final spent = ExpenseCategory.values.where((c) => month.of(c) > 0).toList();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9E3D5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('This month', style: TextStyle(fontSize: 12, color: Color(0xFF927160))),
          const SizedBox(height: 4),
          Text(
            '₹ ${month.total.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
          Text(
            '${month.entries} ${month.entries == 1 ? 'entry' : 'entries'}'
            '  ·  today ₹ ${summary.today.total.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF927160)),
          ),
          if (spent.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final category in spent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${category.label} ₹ ${month.of(category).toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: category.color,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
