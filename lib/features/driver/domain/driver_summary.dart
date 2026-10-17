import '../../../shared/models/tanker_info.dart';
import '../../../shared/utils/json_read.dart';

/// Today's workload at a glance, as `DriverSummaryController` returns it.
class DriverSummary {
  const DriverSummary({
    required this.fullName,
    required this.todayAssigned,
    required this.todayDelivered,
    required this.todayTankers,
    this.tanker,
  });

  final String fullName;
  final TankerInfo? tanker;
  final int todayAssigned;
  final int todayDelivered;

  /// Tanker-loads delivered today, not money: a salaried driver earns nothing
  /// per order, so there is no daily earning to show.
  final int todayTankers;

  factory DriverSummary.fromJson(Map<String, dynamic> json) {
    final driver = JsonRead.asMap(json['driver']);
    final today = JsonRead.asMap(json['today']);

    return DriverSummary(
      fullName: JsonRead.asString(driver['full_name']),
      tanker: driver['tanker'] is Map<String, dynamic>
          ? TankerInfo.fromJson(driver['tanker'] as Map<String, dynamic>)
          : null,
      todayAssigned: JsonRead.asInt(today['assigned']),
      todayDelivered: JsonRead.asInt(today['delivered']),
      todayTankers: JsonRead.asInt(today['tankers']),
    );
  }
}
