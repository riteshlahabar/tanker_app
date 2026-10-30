import 'package:flutter/material.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../../domain/admin_report_result.dart';
import '../../domain/daily_delivery_row.dart';
import 'daily_delivery_hero.dart';
import 'daily_delivery_tile.dart';

/// The Daily Delivery Summary, drawn as a headline over a card per day
/// instead of a seven-column table.
///
/// The whole thing scrolls as one list rather than pinning the hero: once the
/// owner is reading days, the headline is the least urgent thing on screen,
/// and keeping it fixed would cost a third of a phone's height to a figure
/// already read. That is the Driver Expenses arrangement, deliberately copied
/// — as [DriverSalaryReportBody] does too.
///
/// Days arrive **newest first** — `DailyDeliveryReport::datesIn()` walks the
/// range backwards — so the list needs no sort control of its own, and every
/// day in the range is present even where nothing traded.
class DailyDeliveryReportBody extends StatelessWidget {
  const DailyDeliveryReportBody({
    super.key,
    required this.rows,
    required this.result,
    required this.scope,
  });

  final List<DailyDeliveryRow> rows;
  final AdminReportResult result;
  final String scope;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: DailyDeliveryHero(result: result, scope: scope),
        ),
        if (rows.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: EmptyState(
              icon: Icons.insights_outlined,
              title: 'No days in this range',
              message: 'Widen the dates above.',
            ),
          )
        else ...[
          const SizedBox(height: 6),
          for (final row in rows) DailyDeliveryTile(row: row),
        ],
      ],
    );
  }
}
