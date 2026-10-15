import '../utils/json_read.dart';

/// A refill spot, as `SpotResource` describes it. `distanceKm` is only
/// present on the nearest-spots query.
class Spot {
  const Spot({
    required this.id,
    required this.name,
    required this.refillCharge,
    required this.isAvailable,
    required this.status,
    this.address,
    this.latitude,
    this.longitude,
    this.waterType,
    this.contactPerson,
    this.contactMobile,
    this.distanceKm,
  });

  final int id;
  final String name;
  final String? address;
  final double? latitude;
  final double? longitude;
  final double refillCharge;
  final String? waterType;
  final String? contactPerson;
  final String? contactMobile;
  final bool isAvailable;

  /// Whether the spot itself is active — distinct from [isAvailable], which
  /// is the owner's day-to-day "usable right now" flag.
  final bool status;
  final double? distanceKm;

  factory Spot.fromJson(Map<String, dynamic> json) => Spot(
        id: JsonRead.asInt(json['id']),
        name: JsonRead.asString(json['name']),
        address: JsonRead.asStringOrNull(json['address']),
        latitude: JsonRead.asDoubleOrNull(json['latitude']),
        longitude: JsonRead.asDoubleOrNull(json['longitude']),
        refillCharge: JsonRead.asDouble(json['refill_charge']),
        waterType: JsonRead.asStringOrNull(json['water_type']),
        contactPerson: JsonRead.asStringOrNull(json['contact_person']),
        contactMobile: JsonRead.asStringOrNull(json['contact_mobile']),
        isAvailable: JsonRead.asBool(json['is_available'], fallback: true),
        status: JsonRead.asBool(json['status'], fallback: true),
        distanceKm: JsonRead.asDoubleOrNull(json['distance_km']),
      );
}
