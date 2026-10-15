import '../utils/json_read.dart';
import 'order_status.dart';

/// One row of an order's `OrderStatusLogResource` timeline.
class OrderStatusLogEntry {
  const OrderStatusLogEntry({
    required this.status,
    required this.label,
    required this.at,
    this.note,
    this.by,
  });

  final OrderStatus status;
  final String label;
  final String? note;
  final String? by;
  final DateTime? at;

  factory OrderStatusLogEntry.fromJson(Map<String, dynamic> json) => OrderStatusLogEntry(
        status: OrderStatus.fromValue(JsonRead.asString(json['status'])),
        label: JsonRead.asString(json['label']),
        note: JsonRead.asStringOrNull(json['note']),
        by: JsonRead.asStringOrNull(json['by']),
        at: JsonRead.asDate(json['at']),
      );
}
