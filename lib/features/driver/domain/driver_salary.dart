import '../../../shared/utils/json_read.dart';

/// One {delivered, tankers, order value} total — the shape `MySalaryController`
/// returns for both the chosen range and "today".
///
/// No earning field: drivers are on a monthly salary, so nothing is earned per
/// delivery and the money that *is* theirs sits on [DriverSalary.monthlySalary]
/// outside the range blocks.
class DeliveryTotals {
  const DeliveryTotals({
    required this.delivered,
    required this.tankers,
    required this.orderValue,
  });

  final int delivered;
  final int tankers;
  final double orderValue;

  factory DeliveryTotals.fromJson(Map<String, dynamic> json) => DeliveryTotals(
        delivered: JsonRead.asInt(json['delivered']),
        tankers: JsonRead.asInt(json['tankers']),
        orderValue: JsonRead.asDouble(json['order_value']),
      );
}

class DriverSalary {
  const DriverSalary({
    required this.monthlySalary,
    required this.from,
    required this.to,
    required this.range,
    required this.today,
  });

  /// A monthly figure. Never divide it by the range — see the controller's
  /// own note on the panel side.
  final double monthlySalary;
  final DateTime from;
  final DateTime to;
  final DeliveryTotals range;
  final DeliveryTotals today;

  factory DriverSalary.fromJson(Map<String, dynamic> json) => DriverSalary(
        monthlySalary: JsonRead.asDouble(json['monthly_salary']),
        from: JsonRead.asDate(json['from']) ?? DateTime.now(),
        to: JsonRead.asDate(json['to']) ?? DateTime.now(),
        range: DeliveryTotals.fromJson(JsonRead.asMap(json['range'])),
        today: DeliveryTotals.fromJson(JsonRead.asMap(json['today'])),
      );
}
