import '../utils/json_read.dart';

/// The driver's assigned vehicle, as `TankerResource` describes it — just
/// enough to show on the driver's own screens.
class TankerInfo {
  const TankerInfo({
    required this.id,
    required this.label,
    required this.vehicleNumber,
  });

  final int id;
  final String label;
  final String vehicleNumber;

  factory TankerInfo.fromJson(Map<String, dynamic> json) => TankerInfo(
        id: JsonRead.asInt(json['id']),
        label: JsonRead.asString(json['label']),
        vehicleNumber: JsonRead.asString(json['vehicle_number']),
      );
}
