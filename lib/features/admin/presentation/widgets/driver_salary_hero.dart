import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../domain/admin_report_result.dart';

/// The headline of the Driver Deliveries & Salary report.
///
/// Drawn as the gradient hero the Driver Expenses screen established for any
/// screen that answers a numeric question: the cream card is for *rows*, and
/// a headline in the same cream would compete with the first driver under it.
///
/// Read in the order the question is asked:
///
/// 1. **what this covers** — "All drivers · 1–27 Oct", or one driver's name.
///    A figure that moves when a filter changes is unreadable without it.
/// 2. **the work** — deliveries, with the tanker-loads beside it, because the
///    report exists to say who did how much.
/// 3. **the money**, as chips: what those deliveries were worth, what the
///    refills cost, what the drivers spent.
/// 4. **the salary, held apart and labelled**, because it is a monthly figure
///    over an arbitrary range. Putting it in the same row as the three above
///    invites adding them into a "total cost", which would be wrong for every
///    range that is not exactly one month.
///
/// The totals come from the server already formatted; nothing here re-sums
/// the rows, so the screen and the owner's nightly WhatsApp cannot drift.
class DriverSalaryHero extends StatelessWidget {
  const DriverSalaryHero({super.key, required this.result, required this.scope});

  final AdminReportResult result;

  /// Who and what the figures are narrowed to, already in words.
  final String scope;

  /// The server's own total keys. A miss just drops that chip — the headline
  /// and the rows are unaffected.
  static const _deliveries = 'Deliveries';
  static const _loads = 'Tankers delivered';
  static const _drivers = 'Drivers';
  static const _orderValue = 'Order value';
  static const _salary = 'Salary per month (not for the range)';
  static const _expenses = 'Expenses in the range';

  @override
  Widget build(BuildContext context) {
    final totals = result.totals;
    final deliveries = totals[_deliveries];

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
                  scope,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.badge_outlined, color: Colors.white24, size: 34),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            deliveries == null ? 'Not totalled' : '$deliveries deliveries',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: deliveries == null ? 20 : 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _secondLine(totals),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 14),
          _chips(totals),
          if (totals[_salary] != null) ...[
            const SizedBox(height: 10),
            _salaryLine(totals[_salary]!),
          ],
        ],
      ),
    );
  }

  String _secondLine(Map<String, String> totals) {
    final parts = <String>[
      if (totals[_loads] != null) '${totals[_loads]} tanker-loads',
      if (totals[_drivers] != null) '${totals[_drivers]} drivers',
    ];

    return parts.isEmpty ? 'No figures for this range.' : parts.join('  ·  ');
  }

  /// Horizontally scrollable: three labelled amounts in a fixed row overflow
  /// on a narrow phone, and "Order value ₹ 12,45,000.00" is the wordiest real
  /// case, not a sample.
  Widget _chips(Map<String, String> totals) {
    final chips = <({String label, String value})>[
      if (totals[_orderValue] != null) (label: 'Order value', value: totals[_orderValue]!),
      if (totals[_expenses] != null) (label: 'Expenses', value: totals[_expenses]!),
    ];

    if (chips.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final chip in chips)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${chip.label}  ${chip.value}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Apart from the chips, and saying in words why: a salary is not a cost of
  /// this range, so it is never added to anything above it.
  Widget _salaryLine(String salary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payments_outlined, size: 15, color: Colors.white70),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Salary  $salary / month',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            'A monthly figure — not the cost of this range, and never added to the expenses.',
            style: TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
