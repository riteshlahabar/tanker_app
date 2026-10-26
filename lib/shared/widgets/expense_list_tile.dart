import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/colors.dart';
import '../models/driver_expense.dart';

/// One expense row, shared by the driver's own list and the admin's.
///
/// Drawn as the master-data card the rest of the app uses — appetit's cream
/// 15px block with a 4px spine — rather than Material's default `Card` +
/// `ListTile`, which was the one list in the app with a white raised card and
/// a drop shadow and read as a screen from a different product.
///
/// The spine takes the **category's** colour, because that is what a page of
/// expenses is scanned by: fuel against everything else. [showDriver] is what
/// separates the two uses — the admin is looking across everybody, so the name
/// leads the row and the category drops to the detail line; a driver already
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
    final colour = expense.category.color;
    final notes = expense.notes?.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Material(
        color: appetitAppContainerColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(15),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: colour),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: colour.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(_icon, color: colour, size: 19),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      showDriver
                                          ? (expense.driverName ?? 'Unknown driver')
                                          : expense.category.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '₹ ${expense.amount.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                showDriver
                                    ? '${expense.category.label}  ·  '
                                        '${_dateFormat.format(expense.expenseDate)}'
                                    : _dateFormat.format(expense.expenseDate),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: appTextColorSecondary,
                                ),
                              ),
                              if (expense.tankerLabel != null || notes != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  [?expense.tankerLabel, ?(notes == null || notes.isEmpty ? null : notes)]
                                      .join('  ·  '),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: appTextColorSecondary,
                                  ),
                                ),
                              ],
                              if (expense.enteredByAdmin) ...[
                                const SizedBox(height: 7),
                                // A driver has no other way to tell a row they
                                // did not enter themselves.
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusPendingColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Added by the office',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: statusPendingColor,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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
