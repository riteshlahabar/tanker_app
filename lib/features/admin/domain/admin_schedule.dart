import '../../../shared/utils/json_read.dart';

/// A standing order, as `DeliveryScheduleResource` describes it.
class AdminSchedule {
  const AdminSchedule({
    required this.id,
    required this.customerId,
    required this.intervalDays,
    required this.pattern,
    required this.isPaused,
    required this.status,
    this.customerName,
    this.customerMobile,
    this.weekdays,
    this.tankerCount,
    this.tankerRate,
    this.deliverySlotId,
    this.deliverySlot,
    this.deliveryTime,
    this.deliveryAddress,
    this.preferredDriverId,
    this.preferredDriver,
    this.startDate,
    this.endDate,
    this.nextDeliveryDate,
    this.pauseUntil,
    this.notes,
  });

  final int id;
  final int customerId;
  final String? customerName;
  final String? customerMobile;

  final int intervalDays;
  final List<int>? weekdays;
  final String pattern;

  final int? tankerCount;

  /// The routine's own rate per tanker. Null means "price each delivery from
  /// whichever tanker goes out", which is the usual case.
  final double? tankerRate;

  /// What one visit comes to, when the routine carries a rate of its own.
  double? get amountPerDelivery =>
      tankerRate == null ? null : tankerRate! * (tankerCount ?? 1);

  /// "1 tanker per delivery" / "3 tankers per delivery".
  String get tankerLabel =>
      '$tankerCount tanker${tankerCount == 1 ? '' : 's'} per delivery';

  final int? deliverySlotId;
  final String? deliverySlot;
  final String? deliveryTime;

  final String? deliveryAddress;

  final int? preferredDriverId;
  final String? preferredDriver;

  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? nextDeliveryDate;

  final bool isPaused;
  final DateTime? pauseUntil;
  final bool status;
  final String? notes;

  factory AdminSchedule.fromJson(Map<String, dynamic> json) => AdminSchedule(
        id: JsonRead.asInt(json['id']),
        customerId: JsonRead.asInt(json['customer_id']),
        customerName: JsonRead.asStringOrNull(json['customer_name']),
        customerMobile: JsonRead.asStringOrNull(json['customer_mobile']),
        intervalDays: JsonRead.asInt(json['interval_days'], fallback: 1),
        weekdays: json['weekdays'] is List
            ? (json['weekdays'] as List).map(JsonRead.asInt).toList()
            : null,
        pattern: JsonRead.asString(json['pattern']),
        tankerCount: JsonRead.asIntOrNull(json['tanker_count']),
        tankerRate: JsonRead.asDoubleOrNull(json['tanker_rate']),
        deliverySlotId: JsonRead.asIntOrNull(json['delivery_slot_id']),
        deliverySlot: JsonRead.asStringOrNull(json['delivery_slot']),
        deliveryTime: JsonRead.asStringOrNull(json['delivery_time']),
        deliveryAddress: JsonRead.asStringOrNull(json['delivery_address']),
        preferredDriverId: JsonRead.asIntOrNull(json['preferred_driver_id']),
        preferredDriver: JsonRead.asStringOrNull(json['preferred_driver']),
        startDate: JsonRead.asDate(json['start_date']),
        endDate: JsonRead.asDate(json['end_date']),
        nextDeliveryDate: JsonRead.asDate(json['next_delivery_date']),
        isPaused: JsonRead.asBool(json['is_paused']),
        pauseUntil: JsonRead.asDate(json['pause_until']),
        status: JsonRead.asBool(json['status'], fallback: true),
        notes: JsonRead.asStringOrNull(json['notes']),
      );
}
