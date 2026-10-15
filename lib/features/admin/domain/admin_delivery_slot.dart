import '../../../shared/utils/json_read.dart';

/// A delivery slot, as `AdminDeliverySlotResource` describes it.
class AdminDeliverySlot {
  const AdminDeliverySlot({
    required this.id,
    required this.name,
    required this.label,
    required this.startTime,
    required this.endTime,
    required this.sortOrder,
    required this.status,
  });

  final int id;
  final String name;
  final String label;
  final String startTime;
  final String endTime;
  final int sortOrder;
  final bool status;

  factory AdminDeliverySlot.fromJson(Map<String, dynamic> json) => AdminDeliverySlot(
        id: JsonRead.asInt(json['id']),
        name: JsonRead.asString(json['name']),
        label: JsonRead.asString(json['label']),
        startTime: JsonRead.asString(json['start_time']),
        endTime: JsonRead.asString(json['end_time']),
        sortOrder: JsonRead.asInt(json['sort_order']),
        status: JsonRead.asBool(json['status'], fallback: true),
      );
}
