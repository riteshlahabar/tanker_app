import '../utils/json_read.dart';

/// A refill spot, as `SpotResource` describes it. The driver finds it by its
/// address and rings `contactMobile` if it is shut — there are no coordinates
/// any more, and no nearest-first query that needed them.
class Spot {
  const Spot({
    required this.id,
    required this.name,
    required this.refillCharge,
    required this.isAvailable,
    required this.status,
    this.address,
    this.waterType,
    this.contactPerson,
    this.contactMobile,
  });

  final int id;
  final String name;
  final String? address;
  final double refillCharge;
  final String? waterType;
  final String? contactPerson;
  final String? contactMobile;
  final bool isAvailable;

  /// Whether the spot itself is active — distinct from [isAvailable], which
  /// is the owner's day-to-day "usable right now" flag.
  final bool status;

  factory Spot.fromJson(Map<String, dynamic> json) => Spot(
        id: JsonRead.asInt(json['id']),
        name: JsonRead.asString(json['name']),
        address: JsonRead.asStringOrNull(json['address']),
        refillCharge: JsonRead.asDouble(json['refill_charge']),
        waterType: JsonRead.asStringOrNull(json['water_type']),
        contactPerson: JsonRead.asStringOrNull(json['contact_person']),
        contactMobile: JsonRead.asStringOrNull(json['contact_mobile']),
        isAvailable: JsonRead.asBool(json['is_available'], fallback: true),
        status: JsonRead.asBool(json['status'], fallback: true),
      );
}
