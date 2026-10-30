import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../domain/admin_report_result.dart';

/// The headline of the Daily Delivery Summary report.
///
/// Same gradient hero the Driver Expenses screen established for any screen
/// that answers a numeric question: the cream card is for *rows*, so a
/// headline in cream would compete with the first day under it.
///
/// Read in the order the owner asks the question:
///
/// 1. **what this covers** — the range, in words. A figure that moves when
///    the range changes is unreadable without it.
/// 2. **what it earned**, because that is why this report is opened.
/// 3. **the work behind it** — deliveries and tanker-loads.
/// 4. **what went wrong**, as chips: orders placed against orders cancelled.
///
/// Every figure is the server's own formatted total. Nothing here re-sums the
/// rows, so this screen and the owner's nightly WhatsApp cannot drift — the
/// same rule `DriverSalaryHero` follows.
class DailyDeliveryHero extends StatelessWidget {
  const DailyDeliveryHero({super.key, required this.result, required this.scope});

  final AdminReportResult result;

  /// What the figures are narrowed to, already in words.
  final String scope;

  /// `DailyDeliveryReport::totals()`' own keys. A miss drops that one chip;
  /// the headline and the rows are unaffected.
  static const _revenue = 'Revenue';
  static const _placed = 'Orders placed';
  static const _delivered = 'Delivered';
  static const _cancelled = 'Cancelled';
  static const _tankers = 'Tankers delivered';

  @override
  Widget build(BuildContext context) {
    final totals = result.totals;
    final revenue = totals[_revenue];

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
                  'Delivered revenue  ·  $scope',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.insights_outlined, color: Colors.white24, size: 34),
            ],
          ),
          const SizedBox(height: 6),
          // FittedBox because "₹ 12,45,000.00" is the wordiest real case on a
          // narrow phone, not a sample.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              revenue ?? 'Not totalled',
              maxLines: 1,
              style: TextStyle(
                color: Colors.white,
                fontSize: revenue == null ? 20 : 30,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _secondLine(totals),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 14),
          _chips(totals),
        ],
      ),
    );
  }

  String _secondLine(Map<String, String> totals) {
    final parts = <String>[
      if (totals[_delivered] != null) '${totals[_delivered]} delivered',
      if (totals[_tankers] != null) '${totals[_tankers]} tanker-loads',
    ];

    return parts.isEmpty ? 'No figures for this range.' : parts.join('  ·  ');
  }

  /// Horizontally scrollable: a fixed row of chips overflows on a narrow
  /// phone, which this app has learned more than once.
  Widget _chips(Map<String, String> totals) {
    final chips = <({String label, String value, bool warn})>[
      if (totals[_placed] != null) (label: 'Placed', value: totals[_placed]!, warn: false),
      if (totals[_cancelled] != null)
        (
          label: 'Cancelled',
          value: totals[_cancelled]!,
          // Tinted only when there actually were cancellations: a red "0" is
          // an alarm about nothing.
          warn: totals[_cancelled] != '0',
        ),
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
                color: chip.warn
                    ? statusCancelledColor.withValues(alpha: 0.55)
                    : Colors.white.withValues(alpha: 0.16),
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
}
