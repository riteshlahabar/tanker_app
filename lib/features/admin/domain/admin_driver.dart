import '../../../shared/models/tanker_info.dart';
import '../../../shared/utils/json_read.dart';

/// A driver, as `DriverResource` describes it.
class AdminDriver {
  const AdminDriver({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.mobile,
    required this.perDeliveryRate,
    required this.status,
    this.address,
    this.tanker,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String mobile;
  final String? address;
  final double perDeliveryRate;
  final bool status;
  final TankerInfo? tanker;

  factory AdminDriver.fromJson(Map<String, dynamic> json) => AdminDriver(
        id: JsonRead.asInt(json['id']),
        firstName: JsonRead.asString(json['first_name']),
        lastName: JsonRead.asString(json['last_name']),
        fullName: JsonRead.asString(json['full_name']),
        mobile: JsonRead.asString(json['mobile']),
        address: JsonRead.asStringOrNull(json['address']),
        perDeliveryRate: JsonRead.asDouble(json['per_delivery_rate']),
        status: JsonRead.asBool(json['status'], fallback: true),
        tanker: json['tanker'] is Map<String, dynamic>
            ? TankerInfo.fromJson(json['tanker'] as Map<String, dynamic>)
            : null,
      );
}
