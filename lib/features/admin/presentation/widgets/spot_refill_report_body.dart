import 'package:flutter/material.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../../domain/admin_report_result.dart';
import '../../domain/spot_refill_row.dart';
import 'spot_refill_hero.dart';
import 'spot_refill_tile.dart';

/// The Filling Point Refill Report, drawn as a headline over a card per
/// point instead of a six-column table.
///
/// Scrolls as one list rather than pinning the hero — once the owner is
/// reading points, the headline is the least urgent thing on screen. That is
/// the Driver Expenses arrangement, deliberately copied, as the other report
/// views do.
///
/// Points arrive **busiest first** (`orderByDesc('refills')`, then by name),
/// so the list needs no sort control of its own, and every point on the books
/// is present — a quiet one is a row of zeroes rather than a missing row.
class SpotRefillReportBody extends StatelessWidget {
  const SpotRefillReportBody({
    super.key,
    required this.rows,
    required this.result,
    required this.scope,
  });

  final List<SpotRefillRow> rows;
  final AdminReportResult result;
  final String scope;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: SpotRefillHero(result: result, scope: scope),
        ),
        if (rows.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: EmptyState(
              icon: Icons.water_drop_outlined,
              title: 'No filling points match',
              message: 'Nothing matches the filters above.',
            ),
          )
        else ...[
          const SizedBox(height: 6),
          for (final row in rows) SpotRefillTile(row: row),
        ],
      ],
    );
  }
}
