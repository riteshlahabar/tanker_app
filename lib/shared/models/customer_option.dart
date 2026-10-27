import '../utils/json_read.dart';

/// A customer as an order form's picker needs them — enough to choose one and
/// pre-fill the delivery address.
///
/// In `shared/` because two roles now read this shape: the admin's New Order
/// screen from `/api/admin/customers`, and the driver's from
/// `/api/driver/customers`. The driver's endpoint answers with
/// `CustomerLookupResource`, which sends exactly these four fields — the
/// admin's sends more, and this model has always ignored the rest.
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
