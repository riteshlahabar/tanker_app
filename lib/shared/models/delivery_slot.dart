import '../utils/json_read.dart';

/// A named delivery window, as `DeliverySlotResource` describes it.
class DeliverySlot {
  const DeliverySlot({
    required this.id,
    required this.name,
    required this.label,
    required this.startTime,
    required this.endTime,
  });

  final int id;
  final String name;
  final String label;
  final String startTime;
  final String endTime;

  factory DeliverySlot.fromJson(Map<String, dynamic> json) => DeliverySlot(
        id: JsonRead.asInt(json['id']),
        name: JsonRead.asString(json['name']),
        label: JsonRead.asString(json['label']),
        startTime: JsonRead.asString(json['start_time']),
        endTime: JsonRead.asString(json['end_time']),
      );
}
