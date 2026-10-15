import '../../../shared/utils/json_read.dart';

/// The customer's own standing-order routine, as `DeliveryScheduleResource`
/// describes it — just what the Home card and My Deliveries header need.
class DeliverySchedule {
  const DeliverySchedule({
    required this.id,
    required this.pattern,
    required this.isPaused,
    this.nextDeliveryDate,
  });

  final int id;
  final String pattern;
  final bool isPaused;
  final DateTime? nextDeliveryDate;

  factory DeliverySchedule.fromJson(Map<String, dynamic> json) => DeliverySchedule(
        id: JsonRead.asInt(json['id']),
        pattern: JsonRead.asString(json['pattern']),
        isPaused: JsonRead.asBool(json['is_paused']),
        nextDeliveryDate: JsonRead.asDate(json['next_delivery_date']),
      );
}
