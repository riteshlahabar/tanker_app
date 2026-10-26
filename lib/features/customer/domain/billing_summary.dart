import '../../../shared/models/order.dart';
import '../../../shared/models/order_status.dart';

/// The customer's own billing, folded out of their orders.
///
/// Three levels, because that is how the owner described the question a
/// customer actually asks: *what do I owe this month*, *which days was that*,
/// and *how was each day's figure reached*. The last one is why every line
/// carries tankers and rate as well as a total — a bill that only shows a
/// total is a bill you have to take on trust.
///
/// Only **delivered** orders count. A pending or cancelled order is not a
/// charge, and a pending one has no price yet anyway.
class BillingSummary {
  const BillingSummary({required this.months, this.truncated = false});

  final List<BillingMonth> months;

  /// True when the history was longer than the screen walked, so the totals
  /// are "the last N orders", not "everything". Said on screen.
  final bool truncated;

  bool get isEmpty => months.isEmpty;

  double get total => months.fold(0, (sum, month) => sum + month.total);

  factory BillingSummary.fromOrders(List<Order> orders, {bool truncated = false}) {
    final delivered = orders
        .where((order) => order.status == OrderStatus.delivered)
        .where((order) => order.billingDate != null)
        .toList();

    final byMonth = <String, List<Order>>{};

    for (final order in delivered) {
      byMonth.putIfAbsent(order.monthKey!, () => []).add(order);
    }

    final months = byMonth.entries
        .map((entry) => BillingMonth.fromOrders(entry.key, entry.value))
        .toList()
      // Newest month first: the one a customer opens the screen for.
      ..sort((a, b) => b.key.compareTo(a.key));

    return BillingSummary(months: months, truncated: truncated);
  }
}

/// One calendar month of deliveries.
class BillingMonth {
  const BillingMonth({
    required this.key,
    required this.month,
    required this.days,
    required this.total,
    required this.tankers,
    required this.deliveries,
  });

  /// `2026-10`, which sorts correctly as a string.
  final String key;
  final DateTime month;
  final List<BillingDay> days;
  final double total;
  final int tankers;
  final int deliveries;

  factory BillingMonth.fromOrders(String key, List<Order> orders) {
    final byDay = <String, List<Order>>{};

    for (final order in orders) {
      byDay.putIfAbsent(order.dayKey!, () => []).add(order);
    }

    final days = byDay.entries.map((entry) => BillingDay.fromOrders(entry.value)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return BillingMonth(
      key: key,
      month: DateTime(int.parse(key.split('-').first), int.parse(key.split('-').last)),
      days: days,
      total: orders.fold(0, (sum, order) => sum + order.orderAmount),
      tankers: orders.fold(0, (sum, order) => sum + (order.tankerCount ?? 1)),
      deliveries: orders.length,
    );
  }
}

/// One day's deliveries, and the orders behind them.
class BillingDay {
  const BillingDay({
    required this.date,
    required this.orders,
    required this.total,
    required this.tankers,
  });

  final DateTime date;
  final List<Order> orders;
  final double total;
  final int tankers;

  /// The rate every load that day was charged at, when they agree. Two
  /// deliveries from differently priced tankers do not, and the day then
  /// shows its lines instead of a single rate.
  double? get sharedRate {
    final rates = orders.map((order) => order.tankerRate).toSet();

    return rates.length == 1 ? rates.first : null;
  }

  factory BillingDay.fromOrders(List<Order> orders) => BillingDay(
        date: orders.first.billingDate!,
        orders: orders,
        total: orders.fold(0, (sum, order) => sum + order.orderAmount),
        tankers: orders.fold(0, (sum, order) => sum + (order.tankerCount ?? 1)),
      );
}
