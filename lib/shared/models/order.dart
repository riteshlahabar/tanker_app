import '../utils/json_read.dart';
import 'order_status.dart';
import 'order_status_log_entry.dart';

/// Who is delivering, as the order's `driver` object names them — just
/// enough for a customer to call about the delivery.
class OrderDriver {
  const OrderDriver({required this.id, required this.fullName, this.mobile});

  final int id;
  final String fullName;
  final String? mobile;

  factory OrderDriver.fromJson(Map<String, dynamic> json) => OrderDriver(
        id: JsonRead.asInt(json['id']),
        fullName: JsonRead.asString(json['full_name']),
        mobile: JsonRead.asStringOrNull(json['mobile']),
      );
}

/// One order, shaped like `OrderListResource` (every field below the
/// `status`/customer-name line) and, once fetched in full, `OrderResource`
/// (everything after) — the detail-only fields stay null until then, which is
/// also how the server tells a list row apart from a fetched detail.
class Order {
  const Order({
    required this.id,
    required this.orderNo,
    required this.status,
    required this.statusLabel,
    required this.isOpen,
    required this.deliveryAddress,
    required this.orderAmount,
    this.deliveryDate,
    this.deliveredAt,
    this.createdAt,
    this.driverName,
    this.tankerNumber,
    this.spotName,
    this.quantityLitres,
    this.deliverySlot,
    this.notes,
    this.cancelReason,
    this.driver,
    this.timeline = const [],
  });

  final int id;
  final String orderNo;
  final OrderStatus status;
  final String statusLabel;
  final bool isOpen;
  final String deliveryAddress;
  final double orderAmount;
  final DateTime? deliveryDate;
  final DateTime? deliveredAt;
  final DateTime? createdAt;
  final String? driverName;
  final String? tankerNumber;
  final String? spotName;

  // Detail-only.
  final int? quantityLitres;
  final String? deliverySlot;
  final String? notes;
  final String? cancelReason;
  final OrderDriver? driver;
  final List<OrderStatusLogEntry> timeline;

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: JsonRead.asInt(json['id']),
        orderNo: JsonRead.asString(json['order_no']),
        status: OrderStatus.fromValue(JsonRead.asString(json['status'])),
        statusLabel: JsonRead.asString(json['status_label']),
        isOpen: JsonRead.asBool(json['is_open'], fallback: true),
        deliveryAddress: JsonRead.asString(json['delivery_address']),
        orderAmount: JsonRead.asDouble(json['order_amount']),
        deliveryDate: JsonRead.asDate(json['delivery_date']),
        deliveredAt: JsonRead.asDate(json['delivered_at']),
        createdAt: JsonRead.asDate(json['created_at']),
        driverName: JsonRead.asStringOrNull(json['driver_name']),
        tankerNumber: JsonRead.asStringOrNull(json['tanker_number']),
        spotName: JsonRead.asStringOrNull(json['spot_name']),
        quantityLitres: JsonRead.asIntOrNull(json['quantity_litres']),
        deliverySlot: JsonRead.asStringOrNull(json['delivery_slot']),
        notes: JsonRead.asStringOrNull(json['notes']),
        cancelReason: JsonRead.asStringOrNull(json['cancel_reason']),
        driver: json['driver'] is Map<String, dynamic>
            ? OrderDriver.fromJson(json['driver'] as Map<String, dynamic>)
            : null,
        timeline: JsonRead.asMapList(json['timeline']).map(OrderStatusLogEntry.fromJson).toList(),
      );
}
