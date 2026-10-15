import '../utils/json_read.dart';

/// One row of a "My Deliveries" / schedule-detail upcoming list, as
/// `UpcomingDateResource` describes it — read the same way whether the
/// customer is looking at their own routine or the admin at any schedule's.
/// `canSkip`/`skipBlockedReason` are resolved server-side by `SkipWindow`
/// against whoever is asking, so the button here only ever mirrors the
/// backend's own rule rather than guessing at it.
class UpcomingDeliveryDate {
  const UpcomingDeliveryDate({
    required this.date,
    required this.dateLabel,
    required this.statusLabel,
    required this.skipped,
    required this.canSkip,
    this.orderId,
    this.orderNo,
    this.skipBlockedReason,
    this.skipReason,
  });

  final DateTime date;
  final String dateLabel;
  final String statusLabel;
  final bool skipped;
  final bool canSkip;
  final int? orderId;
  final String? orderNo;
  final String? skipBlockedReason;
  final String? skipReason;

  factory UpcomingDeliveryDate.fromJson(Map<String, dynamic> json) => UpcomingDeliveryDate(
        date: JsonRead.asDate(json['date']) ?? DateTime.now(),
        dateLabel: JsonRead.asString(json['date_label']),
        statusLabel: JsonRead.asString(json['status_label']),
        skipped: JsonRead.asBool(json['skipped']),
        canSkip: JsonRead.asBool(json['can_skip']),
        orderId: JsonRead.asIntOrNull(json['order_id']),
        orderNo: JsonRead.asStringOrNull(json['order_no']),
        skipBlockedReason: JsonRead.asStringOrNull(json['skip_blocked_reason']),
        skipReason: JsonRead.asStringOrNull(json['skip_reason']),
      );
}
