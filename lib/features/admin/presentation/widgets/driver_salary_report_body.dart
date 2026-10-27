import 'package:flutter/material.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../../domain/admin_report_result.dart';
import '../../domain/driver_salary_row.dart';
import 'driver_salary_hero.dart';
import 'driver_salary_tile.dart';

/// The Driver Deliveries & Salary report, drawn as a headline over a card per
/// driver instead of a nine-column table.
///
/// The whole thing scrolls as one list rather than pinning the hero: once the
/// owner is reading drivers, the headline is the least urgent thing on screen,
/// and keeping it fixed would cost a third of a phone's height to a figure
/// already read. That is the Driver Expenses screen's arrangement, which this
/// deliberately copies.
///
/// Drivers arrive **busiest first** — the server orders by delivered count —
/// so the list needs no sort control of its own.
class DriverSalaryReportBody extends StatelessWidget {
  const DriverSalaryReportBody({
    super.key,
    required this.rows,
    required this.result,
    required this.scope,
  });

  final List<DriverSalaryRow> rows;
  final AdminReportResult result;
  final String scope;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: DriverSalaryHero(result: result, scope: scope),
        ),
        if (rows.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: EmptyState(
              icon: Icons.badge_outlined,
              title: 'No drivers for this range',
              message: 'Nothing matches the filters above.',
            ),
          )
        else ...[
          const SizedBox(height: 6),
          for (final row in rows) DriverSalaryTile(row: row),
        ],
      ],
    );
  }
}
