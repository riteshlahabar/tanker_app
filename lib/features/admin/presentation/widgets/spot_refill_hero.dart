import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../domain/admin_report_result.dart';

/// The headline of the Filling Point Refill Report.
///
/// Same gradient hero the Driver Expenses screen established for a screen
/// that answers a numeric question — the cream card is for rows, so a
/// headline in cream would compete with the first point under it.
///
/// The question this report is opened to ask is **what the water cost at the
/// spot**, so that is the headline; the counts behind it are the second line.
/// Every figure is the server's own formatted total — nothing here re-sums
/// the rows, so this screen and the spreadsheet cannot drift.
class SpotRefillHero extends StatelessWidget {
  const SpotRefillHero({super.key, required this.result, required this.scope});

  final AdminReportResult result;

  /// What the figures are narrowed to, already in words.
  final String scope;

  /// `SpotRefillReport::totals()`' own keys. A miss drops that one chip; the
  /// headline and the rows are unaffected.
  static const _cost = 'Total refill cost';
  static const _refills = 'Refills';
  static const _used = 'Filling points used';

  @override
  Widget build(BuildContext context) {
    final totals = result.totals;
    final cost = totals[_cost];

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
                  'Spent on refills  ·  $scope',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.water_drop_outlined, color: Colors.white24, size: 34),
            ],
          ),
          const SizedBox(height: 6),
          // FittedBox because "₹ 2,45,000.00" is the wordiest real case on a
          // narrow phone, not a sample.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              cost ?? 'Not totalled',
              maxLines: 1,
              style: TextStyle(
                color: Colors.white,
                fontSize: cost == null ? 20 : 30,
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
    final refills = totals[_refills];

    if (refills == null) return 'No figures for this range.';

    return refills == '1' ? '1 refill in the range' : '$refills refills in the range';
  }

  /// Horizontally scrollable: a fixed row of chips overflows on a narrow
  /// phone, which this app has learned more than once.
  Widget _chips(Map<String, String> totals) {
    final chips = <({String label, String value})>[
      if (totals[_used] != null) (label: 'Points used', value: totals[_used]!),
      if (totals[_refills] != null) (label: 'Refills', value: totals[_refills]!),
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
}
