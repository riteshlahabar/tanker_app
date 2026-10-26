import '../../../shared/utils/json_read.dart';

/// A tanker, as `TankerResource` describes it.
class AdminTanker {
  const AdminTanker({
    required this.id,
    required this.vehicleName,
    required this.vehicleNumber,
    required this.label,
    required this.status,
    this.capacityLitres,
    this.tankerRate,
    this.modelYear,
    this.rcNumber,
    this.insuranceExpiry,
    this.currentDriver,
  });

  final int id;
  final String vehicleName;
  final String vehicleNumber;
  final String label;
  final bool status;
  final int? capacityLitres;

  /// What one tanker-load from this vehicle costs. Null falls through to the
  /// default_tanker_rate setting.
  final double? tankerRate;
  final int? modelYear;
  final String? rcNumber;
  final DateTime? insuranceExpiry;
  final String? currentDriver;

  factory AdminTanker.fromJson(Map<String, dynamic> json) => AdminTanker(
        id: JsonRead.asInt(json['id']),
        vehicleName: JsonRead.asString(json['vehicle_name']),
        vehicleNumber: JsonRead.asString(json['vehicle_number']),
        label: JsonRead.asString(json['label']),
        status: JsonRead.asBool(json['status'], fallback: true),
        capacityLitres: JsonRead.asIntOrNull(json['capacity_litres']),
        tankerRate: JsonRead.asDoubleOrNull(json['tanker_rate']),
        modelYear: JsonRead.asIntOrNull(json['model_year']),
        rcNumber: JsonRead.asStringOrNull(json['rc_number']),
        insuranceExpiry: JsonRead.asDate(json['insurance_expiry']),
        currentDriver: JsonRead.asStringOrNull(json['current_driver']),
      );
}
