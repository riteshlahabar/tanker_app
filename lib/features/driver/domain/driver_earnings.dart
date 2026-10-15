import '../../../shared/utils/json_read.dart';

/// One {delivered, earning, order value} total — the shape `MyEarningsController`
/// returns for both the chosen range and "today".
class EarningsTotals {
  const EarningsTotals({
    required this.delivered,
    required this.earning,
    required this.orderValue,
  });

  final int delivered;
  final double earning;
  final double orderValue;

  factory EarningsTotals.fromJson(Map<String, dynamic> json) => EarningsTotals(
        delivered: JsonRead.asInt(json['delivered']),
        earning: JsonRead.asDouble(json['earning']),
        orderValue: JsonRead.asDouble(json['order_value']),
      );
}

class DriverEarnings {
  const DriverEarnings({
    required this.from,
    required this.to,
    required this.range,
    required this.today,
  });

  final DateTime from;
  final DateTime to;
  final EarningsTotals range;
  final EarningsTotals today;

  factory DriverEarnings.fromJson(Map<String, dynamic> json) => DriverEarnings(
        from: JsonRead.asDate(json['from']) ?? DateTime.now(),
        to: JsonRead.asDate(json['to']) ?? DateTime.now(),
        range: EarningsTotals.fromJson(JsonRead.asMap(json['range'])),
        today: EarningsTotals.fromJson(JsonRead.asMap(json['today'])),
      );
}
