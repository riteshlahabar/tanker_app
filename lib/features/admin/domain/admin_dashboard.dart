import '../../../shared/models/order.dart';
import '../../../shared/utils/json_read.dart';

/// The nine counters `DashboardService::summary()` returns, plus the
/// outstanding orders listed under them.
class AdminDashboard {
  const AdminDashboard({
    required this.tankers,
    required this.drivers,
    required this.customers,
    required this.scheduledTomorrow,
    required this.ordersToday,
    required this.pending,
    required this.deliveredToday,
    required this.revenueToday,
    required this.tankersDeliveredToday,
    required this.openOrders,
    required this.openTotal,
  });

  final int tankers;
  final int drivers;
  final int customers;
  final int scheduledTomorrow;
  final int ordersToday;
  final int pending;
  final int deliveredToday;
  final double revenueToday;
  final int tankersDeliveredToday;

  /// Every order still to be delivered, newest first — capped by the server at
  /// ten. A delivered or cancelled order is simply absent from the next fetch,
  /// which is what makes the dashboard drop it on its own.
  final List<Order> openOrders;

  /// How many are outstanding altogether, so the screen can say that its list
  /// is only the latest few.
  final int openTotal;

  bool get hasMoreOpenThanShown => openTotal > openOrders.length;

  factory AdminDashboard.fromJson(Map<String, dynamic> json) => AdminDashboard(
        tankers: JsonRead.asInt(json['tankers']),
        drivers: JsonRead.asInt(json['drivers']),
        customers: JsonRead.asInt(json['customers']),
        scheduledTomorrow: JsonRead.asInt(json['scheduled_tomorrow']),
        ordersToday: JsonRead.asInt(json['orders_today']),
        pending: JsonRead.asInt(json['pending']),
        deliveredToday: JsonRead.asInt(json['delivered_today']),
        revenueToday: JsonRead.asDouble(json['revenue_today']),
        tankersDeliveredToday: JsonRead.asInt(json['tankers_delivered_today']),
        // Absent on an older panel build rather than null, so this reads the
        // key defensively and simply shows no list.
        openOrders: ((json['open_orders'] as List<dynamic>?) ?? const [])
            .map((item) => Order.fromJson(item as Map<String, dynamic>))
            .toList(),
        openTotal: JsonRead.asInt(json['open_total']),
      );
}
