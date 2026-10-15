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
    this.quantityLitres,
    this.orderAmount,
    this.deliverySlotId,
    this.deliverySlot,
    this.deliveryTime,
    this.deliveryAddress,
    this.latitude,
    this.longitude,
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

  final int? quantityLitres;
  final double? orderAmount;

  final int? deliverySlotId;
  final String? deliverySlot;
  final String? deliveryTime;

  final String? deliveryAddress;
  final double? latitude;
  final double? longitude;

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
        quantityLitres: JsonRead.asIntOrNull(json['quantity_litres']),
        orderAmount: JsonRead.asDoubleOrNull(json['order_amount']),
        deliverySlotId: JsonRead.asIntOrNull(json['delivery_slot_id']),
        deliverySlot: JsonRead.asStringOrNull(json['delivery_slot']),
        deliveryTime: JsonRead.asStringOrNull(json['delivery_time']),
        deliveryAddress: JsonRead.asStringOrNull(json['delivery_address']),
        latitude: JsonRead.asDoubleOrNull(json['latitude']),
        longitude: JsonRead.asDoubleOrNull(json['longitude']),
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
