import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/colors.dart';
import '../../../../shared/models/driver_expense.dart';
import '../../domain/admin_expense_repository.dart';

/// What the admin's Driver Expenses screen is spending, above the rows it is
/// spending it on.
///
/// Drawn as the gradient hero the driver's home screen uses, because this is
/// the one figure the screen exists to answer and it has to read before
/// anything else on the page. The cream master-data card is for *rows*; a
/// headline in the same cream would compete with the first expense under it.
///
/// Three lines, in the order the question is actually asked:
///
/// 1. **what this total covers** — "All drivers · all time", or "Ramesh Patil
///    · Fuel · 1–26 Oct". Without it a figure that moves when a chip is tapped
///    is unexplainable.
/// 2. **the figure**, and the entry count beside it.
/// 3. **this month across everybody**, which deliberately ignores the filters
///    — a fixed reference to read while narrowing, and the number the owner
///    actually budgets against.
///
/// The category breakdown scrolls horizontally: five labelled amounts in a
/// fixed row overflow on a narrow phone, and "Maintenance ₹ 1,24,500" is the
/// wordiest real case, not "Food ₹ 0".
class AdminExpenseTotalsCard extends StatelessWidget {
  const AdminExpenseTotalsCard({super.key, required this.summary, required this.filter});

  /// Null means **not totalled** — the first load has not landed, or the
  /// summary call failed while the list succeeded. Never drawn as ₹ 0, which
  /// would read as "nothing was spent".
  final AdminExpenseSummary? summary;

  final AdminExpenseFilter filter;

  static final _dayMonth = DateFormat('d MMM');
  static final _money = NumberFormat.decimalPattern('en_IN');

  /// The filters in words, in the order they narrow: who, what, when.
  String get _scope {
    final parts = <String>[
      filter.driverName ?? 'All drivers',
      ?filter.category?.label,
      if (filter.hasRange)
        '${_dayMonth.format(filter.from!)} – ${_dayMonth.format(filter.to!)}'
      else
        'all time',
      if (filter.search != null && filter.search!.isNotEmpty) '"${filter.search}"',
    ];

    return parts.join('  ·  ');
  }

  @override
  Widget build(BuildContext context) {
    final totals = summary?.filtered;
    final month = summary?.month;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [appBottomNavColor, Color(0xFF6A4A72)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _scope,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.receipt_long, color: Colors.white24, size: 34),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            totals == null ? 'Not totalled' : '₹ ${_money.format(totals.total.round())}',
            style: TextStyle(
              color: Colors.white,
              fontSize: totals == null ? 20 : 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _secondLine(totals, month),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          if (totals != null) ..._breakdown(totals),
        ],
      ),
    );
  }

  String _secondLine(ExpenseTotals? totals, ExpenseTotals? month) {
    if (totals == null) {
      return 'Spending could not be totalled — the list below is still complete.';
    }

    final entries = '${totals.entries} ${totals.entries == 1 ? 'entry' : 'entries'}';

    // The month reference is dropped when the filters already *are* this
    // month and every driver, or the same figure would be printed twice.
    return month == null || month.total == totals.total
        ? entries
        : '$entries  ·  this month ₹ ${_money.format(month.total.round())}';
  }

  List<Widget> _breakdown(ExpenseTotals totals) {
    final spent = ExpenseCategory.values.where((c) => totals.of(c) > 0).toList();

    if (spent.isEmpty) return const [];

    return [
      const SizedBox(height: 14),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final category in spent)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(color: category.color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${category.label} ₹ ${_money.format(totals.of(category).round())}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ];
  }
}
