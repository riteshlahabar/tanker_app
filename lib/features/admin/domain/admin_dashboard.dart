import '../../../shared/utils/json_read.dart';

/// The nine counters `DashboardService::summary()` returns.
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
    required this.driverEarningToday,
  });

  final int tankers;
  final int drivers;
  final int customers;
  final int scheduledTomorrow;
  final int ordersToday;
  final int pending;
  final int deliveredToday;
  final double revenueToday;
  final double driverEarningToday;

  factory AdminDashboard.fromJson(Map<String, dynamic> json) => AdminDashboard(
        tankers: JsonRead.asInt(json['tankers']),
        drivers: JsonRead.asInt(json['drivers']),
        customers: JsonRead.asInt(json['customers']),
        scheduledTomorrow: JsonRead.asInt(json['scheduled_tomorrow']),
        ordersToday: JsonRead.asInt(json['orders_today']),
        pending: JsonRead.asInt(json['pending']),
        deliveredToday: JsonRead.asInt(json['delivered_today']),
        revenueToday: JsonRead.asDouble(json['revenue_today']),
        driverEarningToday: JsonRead.asDouble(json['driver_earning_today']),
      );
}
