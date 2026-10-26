import '../../../shared/utils/json_read.dart';

/// A customer as the New Order picker needs them — enough to pre-fill the
/// order form once one is chosen.
class CustomerOption {
  const CustomerOption({
    required this.id,
    required this.fullName,
    this.mobile,
    this.address,
  });

  final int id;
  final String fullName;
  final String? mobile;
  final String? address;

  factory CustomerOption.fromJson(Map<String, dynamic> json) => CustomerOption(
        id: JsonRead.asInt(json['id']),
        fullName: JsonRead.asString(json['full_name']),
        mobile: JsonRead.asStringOrNull(json['mobile']),
        address: JsonRead.asStringOrNull(json['address']),
      );
}
