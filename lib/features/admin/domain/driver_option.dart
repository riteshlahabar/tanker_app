import '../../../shared/utils/json_read.dart';

/// A driver as the Assign picker needs them — just enough to show in a list
/// and refuse the ones with no tanker before the server has to say so.
class DriverOption {
  const DriverOption({
    required this.id,
    required this.fullName,
    required this.hasTanker,
    this.mobile,
  });

  final int id;
  final String fullName;
  final String? mobile;
  final bool hasTanker;

  factory DriverOption.fromJson(Map<String, dynamic> json) => DriverOption(
        id: JsonRead.asInt(json['id']),
        fullName: JsonRead.asString(json['full_name']),
        mobile: JsonRead.asStringOrNull(json['mobile']),
        hasTanker: json['tanker'] != null,
      );
}
