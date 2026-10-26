import '../../../shared/utils/json_read.dart';

/// A driver as the Assign and New Order pickers need them — enough to show in
/// a list, refuse the ones with no tanker before the server has to say so,
/// and price the order.
///
/// The rate matters here because the price of an order *is* the rate of the
/// tanker the chosen driver holds: picking a driver on the New Order screen is
/// what fills the rate in.
class DriverOption {
  const DriverOption({
    required this.id,
    required this.fullName,
    required this.hasTanker,
    this.mobile,
    this.tankerLabel,
    this.tankerRate,
  });

  final int id;
  final String fullName;
  final String? mobile;
  final bool hasTanker;

  /// "MH12AB1234 — Big Tanker", as the server composes it.
  final String? tankerLabel;

  /// What one load from that tanker costs. Null, or 0, means the vehicle has
  /// no rate set — the order would save at ₹ 0 unless a rate is typed.
  final double? tankerRate;

  factory DriverOption.fromJson(Map<String, dynamic> json) {
    final tanker = json['tanker'] is Map<String, dynamic>
        ? json['tanker'] as Map<String, dynamic>
        : null;

    return DriverOption(
      id: JsonRead.asInt(json['id']),
      fullName: JsonRead.asString(json['full_name']),
      mobile: JsonRead.asStringOrNull(json['mobile']),
      hasTanker: tanker != null,
      tankerLabel: tanker == null ? null : JsonRead.asStringOrNull(tanker['label']),
      tankerRate: tanker == null ? null : JsonRead.asDoubleOrNull(tanker['tanker_rate']),
    );
  }
}
