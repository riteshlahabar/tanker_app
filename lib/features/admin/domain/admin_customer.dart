import '../../../shared/utils/json_read.dart';

/// A customer, as `CustomerResource` describes it.
class AdminCustomer {
  const AdminCustomer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.mobile,
    required this.canSelfOrder,
    required this.status,
    this.address,
    this.latitude,
    this.longitude,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String mobile;
  final String? address;
  final double? latitude;
  final double? longitude;
  final bool canSelfOrder;
  final bool status;

  factory AdminCustomer.fromJson(Map<String, dynamic> json) => AdminCustomer(
        id: JsonRead.asInt(json['id']),
        firstName: JsonRead.asString(json['first_name']),
        lastName: JsonRead.asString(json['last_name']),
        fullName: JsonRead.asString(json['full_name']),
        mobile: JsonRead.asString(json['mobile']),
        address: JsonRead.asStringOrNull(json['address']),
        latitude: JsonRead.asDoubleOrNull(json['latitude']),
        longitude: JsonRead.asDoubleOrNull(json['longitude']),
        canSelfOrder: JsonRead.asBool(json['can_self_order'], fallback: true),
        status: JsonRead.asBool(json['status'], fallback: true),
      );
}
