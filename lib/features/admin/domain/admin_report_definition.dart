import '../../../shared/utils/json_read.dart';

/// One entry of `GET /api/admin/reports`'s menu — enough to list the six
/// reports and know which extra filter (if any) each one takes.
class AdminReportDefinition {
  const AdminReportDefinition({
    required this.key,
    required this.title,
    required this.filterFields,
  });

  final String key;
  final String title;

  /// Any of `driver`/`customer`/`spot`/`tanker`/`search` — the date range is
  /// always shown regardless of what's listed here.
  final List<String> filterFields;

  factory AdminReportDefinition.fromJson(Map<String, dynamic> json) => AdminReportDefinition(
        key: JsonRead.asString(json['key']),
        title: JsonRead.asString(json['title']),
        filterFields: json['filters'] is List
            ? (json['filters'] as List).map((f) => f.toString()).toList()
            : const [],
      );
}
