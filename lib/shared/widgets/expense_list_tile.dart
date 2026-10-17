import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/driver_expense.dart';

/// One expense row, shared by the driver's own list and the admin's.
///
/// The category carries the colour, and an entry the office made is marked — a
/// driver has no other way to tell where a row came from. [showDriver] is what
/// separates the two uses: the admin is looking across everybody, so the name
/// leads the row and the category drops to the subtitle; a driver already
/// knows whose expense it is.
class ExpenseListTile extends StatelessWidget {
  const ExpenseListTile({
    super.key,
    required this.expense,
    this.onTap,
    this.showDriver = false,
  });

  final DriverExpense expense;
  final VoidCallback? onTap;
  final bool showDriver;

  static final _dateFormat = DateFormat('d MMM yyyy');

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: expense.category.color.withValues(alpha: 0.12),
          child: Icon(_icon, color: expense.category.color, size: 20),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                showDriver ? (expense.driverName ?? 'Unknown driver') : expense.category.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '₹ ${expense.amount.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              showDriver
                  ? '${expense.category.label} · ${_dateFormat.format(expense.expenseDate)}'
                  : _dateFormat.format(expense.expenseDate),
            ),
            if (expense.tankerLabel != null)
              Text(expense.tankerLabel!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            if (expense.notes != null && expense.notes!.isNotEmpty)
              Text(
                expense.notes!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            if (expense.enteredByAdmin)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Added by the office',
                  style: TextStyle(fontSize: 11, color: Colors.orange.shade800),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData get _icon => switch (expense.category) {
        ExpenseCategory.fuel => Icons.local_gas_station_outlined,
        ExpenseCategory.toll => Icons.toll_outlined,
        ExpenseCategory.maintenance => Icons.build_outlined,
        ExpenseCategory.food => Icons.restaurant_outlined,
        ExpenseCategory.other => Icons.receipt_long_outlined,
      };
}
