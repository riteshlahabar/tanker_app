import '../../../shared/utils/json_read.dart';

/// `GET /api/admin/reports/{key}`'s response — headings/rows/totals, the same
/// shape the web panel's one shared report view reads.
class AdminReportResult {
  const AdminReportResult({
    required this.key,
    required this.title,
    required this.rangeLabel,
    required this.headings,
    required this.rows,
    required this.totals,
  });

  final String key;
  final String title;
  final String rangeLabel;
  final List<String> headings;
  final List<List<dynamic>> rows;
  final Map<String, String> totals;

  factory AdminReportResult.fromJson(Map<String, dynamic> json) => AdminReportResult(
        key: JsonRead.asString(json['key']),
        title: JsonRead.asString(json['title']),
        rangeLabel: JsonRead.asString(JsonRead.asMap(json['range'])['label']),
        headings: json['headings'] is List
            ? (json['headings'] as List).map((h) => h.toString()).toList()
            : const [],
        rows: json['rows'] is List
            ? (json['rows'] as List)
                .map((row) => row is List ? row : const [])
                .toList()
            : const [],
        totals: json['totals'] is Map
            ? (json['totals'] as Map).map((k, v) => MapEntry(k.toString(), v.toString()))
            : const {},
      );
}
