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
    this.tankerRate = 0,
    this.deliveryDate,
    this.deliveredAt,
    this.createdAt,
    this.customerName,
    this.driverName,
    this.tankerNumber,
    this.spotId,
    this.spotName,
    this.tankerCount,
    this.deliverySlot,
    this.notes,
    this.cancelReason,
    this.isScheduled = false,
    this.driver,
    this.timeline = const [],
  });

  final int id;
  final String orderNo;
  final OrderStatus status;
  final String statusLabel;
  final bool isOpen;
  final String deliveryAddress;

  /// The whole price rule travels with every order, list rows included:
  /// `tankerRate × tankerCount = orderAmount`. 0 means no tanker has been
  /// chosen yet, so the price is not known — not that the water is free.
  final double tankerRate;
  final double orderAmount;
  final DateTime? deliveryDate;
  final DateTime? deliveredAt;
  final DateTime? createdAt;
  /// Only the admin list carries this — a customer reading their own orders
  /// already knows whose they are, and a driver sees the address instead.
  final String? customerName;
  final String? driverName;
  final String? tankerNumber;

  /// The filling point the admin chose when assigning, if they chose one.
  ///
  /// The **id** arrives on every order, list rows included; [spotName] only
  /// when the server loaded the relation. That split is deliberate: the
  /// driver's app has to know *whether* a point was already picked before it
  /// decides whether to ask for one, and a name it may not have been sent is
  /// no basis for that decision.
  final int? spotId;
  final String? spotName;

  /// An admin already named the filling point, so the driver can start
  /// filling without being asked where.
  bool get hasSpot => spotId != null;

  // Detail-only.
  final int? tankerCount;
  final String? deliverySlot;
  final String? notes;
  final String? cancelReason;

  /// This delivery came from a standing order. Detail-only, so a list row
  /// always reads false.
  final bool isScheduled;

  /// "1 tanker" / "3 tankers" — water is sold by the tanker-load, so this is
  /// how every screen names the quantity. Here rather than in each screen
  /// because all three roles show the same line.
  String get tankerLabel => '$tankerCount tanker${tankerCount == 1 ? '' : 's'}';

  /// The amount, or what 0 actually means.
  ///
  /// An order has no price until a tanker is chosen, so "₹ 0" on a pending
  /// booking reads as "free" when it means "not worked out yet". The same rule
  /// the driver and tanker lists already follow for an unset salary or rate.
  String get amountLabel =>
      orderAmount > 0 ? '₹ ${orderAmount.toStringAsFixed(0)}' : 'Not priced yet';

  /// "2 × ₹ 1,500" — how the total was reached, for a detail screen.
  String? get priceBreakdown => tankerRate > 0 && tankerCount != null
      ? '$tankerCount × ₹ ${tankerRate.toStringAsFixed(0)}'
      : null;

  /// The day this order belongs to on a bill: the day it was **delivered**,
  /// falling back to the day it was due.
  ///
  /// Delivery is what is charged for, so a delivery that slipped past
  /// midnight is billed on the night it actually happened — which is also the
  /// date the customer remembers. Date only, so two deliveries on one day
  /// group together whatever the clock said.
  DateTime? get billingDate {
    final day = deliveredAt ?? deliveryDate;

    return day == null ? null : DateTime(day.year, day.month, day.day);
  }

  /// `2026-10`, and `2026-10-26` — keys that group and sort as plain strings.
  String? get monthKey => billingDate == null
      ? null
      : '${billingDate!.year}-${billingDate!.month.toString().padLeft(2, '0')}';

  String? get dayKey =>
      billingDate == null ? null : '$monthKey-${billingDate!.day.toString().padLeft(2, '0')}';

  final OrderDriver? driver;
  final List<OrderStatusLogEntry> timeline;

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: JsonRead.asInt(json['id']),
        orderNo: JsonRead.asString(json['order_no']),
        status: OrderStatus.fromValue(JsonRead.asString(json['status'])),
        statusLabel: JsonRead.asString(json['status_label']),
        isOpen: JsonRead.asBool(json['is_open'], fallback: true),
        deliveryAddress: JsonRead.asString(json['delivery_address']),
        tankerRate: JsonRead.asDouble(json['tanker_rate']),
        orderAmount: JsonRead.asDouble(json['order_amount']),
        deliveryDate: JsonRead.asDate(json['delivery_date']),
        deliveredAt: JsonRead.asDate(json['delivered_at']),
        createdAt: JsonRead.asDate(json['created_at']),
        customerName: JsonRead.asStringOrNull(json['customer_name']),
        driverName: JsonRead.asStringOrNull(json['driver_name']),
        tankerNumber: JsonRead.asStringOrNull(json['tanker_number']),
        spotId: JsonRead.asIntOrNull(json['spot_id']),
        spotName: JsonRead.asStringOrNull(json['spot_name']),
        tankerCount: JsonRead.asIntOrNull(json['tanker_count']),
        deliverySlot: JsonRead.asStringOrNull(json['delivery_slot']),
        notes: JsonRead.asStringOrNull(json['notes']),
        cancelReason: JsonRead.asStringOrNull(json['cancel_reason']),
        isScheduled: JsonRead.asBool(json['is_scheduled'], fallback: false),
        driver: json['driver'] is Map<String, dynamic>
            ? OrderDriver.fromJson(json['driver'] as Map<String, dynamic>)
            : null,
        timeline: JsonRead.asMapList(json['timeline']).map(OrderStatusLogEntry.fromJson).toList(),
      );
}
