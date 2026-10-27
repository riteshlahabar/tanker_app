import '../utils/json_read.dart';

/// The driver's assigned vehicle, as `TankerResource` describes it — just
/// enough to show on the driver's own screens.
class TankerInfo {
  const TankerInfo({
    required this.id,
    required this.label,
    required this.vehicleNumber,
    this.tankerRate,
  });

  final int id;
  final String label;
  final String vehicleNumber;

  /// What one load from this vehicle sells for. `TankerResource` has always
  /// sent it; the driver's own order form is what finally reads it, to
  /// pre-fill the rate without a second request.
  ///
  /// Null, or 0, means the owner has not priced this vehicle — which the forms
  /// write as "Not priced yet", never ₹ 0.
  final double? tankerRate;

  /// The rate as a number to compute with, where "not set" and "free" both
  /// have to come out as 0 and be labelled by the caller.
  double get rate => tankerRate ?? 0;

  factory TankerInfo.fromJson(Map<String, dynamic> json) => TankerInfo(
        id: JsonRead.asInt(json['id']),
        label: JsonRead.asString(json['label']),
        vehicleNumber: JsonRead.asString(json['vehicle_number']),
        tankerRate: JsonRead.asDoubleOrNull(json['tanker_rate']),
      );
}
