import 'package:flutter/material.dart';

import '../../domain/admin_report_result.dart';
import '../../domain/daily_delivery_row.dart';
import '../../domain/driver_salary_row.dart';
import '../../domain/spot_refill_row.dart';
import 'daily_delivery_report_body.dart';
import 'driver_salary_report_body.dart';
import 'spot_refill_report_body.dart';

/// **The one place a report's own view is registered.**
///
/// Every report answers in the same headings/rows/totals shape, so
/// `ReportDetailScreen` can draw any of them as a generic table. A report
/// that deserves better brings its own body, and this is the list of which
/// ones do — kept out of the screen so adding the next one is a three-line
/// entry here rather than another branch in a widget that already owns the
/// filter bar, the entity pickers and four loading states.
///
/// Each `…Row.fromResult` returns null unless the result is *its* report with
/// *exactly* its expected headings, so the order below does not matter and a
/// report whose columns changed on the server falls through to the table —
/// which is always right, because it draws whatever it is given.
///
/// Returns null when no view claims the result: the caller then draws the
/// generic table **and** the generic totals strip above it, which a report
/// with its own view does not want, since each hero states its own figures.
class ReportBodyRegistry {
  ReportBodyRegistry._();

  static Widget? bodyFor(AdminReportResult result, String scope) {
    final salary = DriverSalaryRow.fromResult(result);

    if (salary != null) {
      return DriverSalaryReportBody(rows: salary, result: result, scope: scope);
    }

    final daily = DailyDeliveryRow.fromResult(result);

    if (daily != null) {
      return DailyDeliveryReportBody(rows: daily, result: result, scope: scope);
    }

    final spots = SpotRefillRow.fromResult(result);

    if (spots != null) {
      return SpotRefillReportBody(rows: spots, result: result, scope: scope);
    }

    return null;
  }
}
