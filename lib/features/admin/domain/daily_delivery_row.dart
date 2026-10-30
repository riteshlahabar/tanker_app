import 'package:intl/intl.dart';

import '../../../shared/utils/json_read.dart';
import 'admin_report_result.dart';

/// One day's line of the **Daily Delivery Summary** report.
///
/// Read by **position**, like [DriverSalaryRow], because every report answers
/// in the same headings + rows shape and a row is a `List`, not an object.
/// That carries the same risk and takes the same precaution: [fromResult]
/// refuses unless the headings are exactly the seven this was written
/// against, and a changed report falls back to the generic table — which is
/// always right, because it draws whatever it is given.
class DailyDeliveryRow {
  const DailyDeliveryRow({
    required this.dateLabel,
    required this.date,
    required this.orders,
    required this.delivered,
    required this.cancelled,
    required this.revenue,
    required this.refillCost,
    required this.tankers,
  });

  /// `DailyDeliveryReport::headings()`, in order.
  static const headings = <String>[
    'Date',
    'Orders',
    'Delivered',
    'Cancelled',
    'Revenue',
    'Refill Cost',
    'Tankers',
  ];

  /// What the server sent — `28 Oct 2026`. Kept verbatim so a day is still
  /// labelled even if [date] could not be parsed.
  final String dateLabel;

  /// The parsed date, for the weekday line. Null if the server's format ever
  /// changes, which costs the weekday and nothing else.
  final DateTime? date;

  final int orders;
  final int delivered;
  final int cancelled;
  final double revenue;
  final double refillCost;

  /// Tanker-**loads** delivered that day, never litres (CLAUDE.md).
  final int tankers;

  /// A day with no deliveries at all. Its ₹ 0 is a true fact about the day,
  /// not a missing price — which is why [revenueIsUnpriced] is separate.
  bool get traded => delivered > 0;

  /// Deliveries were made and yet the revenue is zero: that is the
  /// unconfigured-pricing case the whole app writes as words rather than
  /// "₹ 0", because a tanker with no `tanker_rate` prices at nothing.
  bool get revenueIsUnpriced => delivered > 0 && revenue <= 0;

  /// Null unless this result is the daily-delivery report, drawn exactly as
  /// expected.
  static List<DailyDeliveryRow>? fromResult(AdminReportResult result) {
    if (result.key != 'daily-delivery') return null;

    if (result.headings.length != headings.length) return null;

    for (var i = 0; i < headings.length; i++) {
      if (result.headings[i] != headings[i]) return null;
    }

    return result.rows.where((row) => row.length == headings.length).map(_fromRow).toList();
  }

  static final _serverFormat = DateFormat('d MMM yyyy');

  static DailyDeliveryRow _fromRow(List<dynamic> row) {
    final label = JsonRead.asString(row[0]);

    return DailyDeliveryRow(
      dateLabel: label,
      date: DateTime.tryParse(label) ?? _tryServerFormat(label),
      orders: JsonRead.asInt(row[1]),
      delivered: JsonRead.asInt(row[2]),
      cancelled: JsonRead.asInt(row[3]),
      // Money arrives as `num` — an integral amount comes without its `.0`,
      // so `as double` would throw (CLAUDE.md rule 7).
      revenue: JsonRead.asDouble(row[4]),
      refillCost: JsonRead.asDouble(row[5]),
      tankers: JsonRead.asInt(row[6]),
    );
  }

  static DateTime? _tryServerFormat(String label) {
    try {
      return _serverFormat.parseStrict(label);
    } catch (_) {
      return null;
    }
  }
}
