import '../../../shared/utils/json_read.dart';

/// What `ScheduleGenerateApiController` reports back after a "Generate Now"
/// run. The server's own summary sentence travels as the response's
/// `message`, which `ApiClient` doesn't surface on success — so the screen
/// builds its own line from these counts instead of needing it.
class AdminGenerateResult {
  const AdminGenerateResult({
    required this.targetDate,
    required this.created,
    required this.skipped,
    required this.failed,
    this.lines = const [],
  });

  final String targetDate;
  final int created;
  final int skipped;
  final int failed;
  final List<String> lines;

  factory AdminGenerateResult.fromJson(Map<String, dynamic> json) => AdminGenerateResult(
        targetDate: JsonRead.asString(json['target_date']),
        created: JsonRead.asInt(json['created']),
        skipped: JsonRead.asInt(json['skipped']),
        failed: JsonRead.asInt(json['failed']),
        lines: json['lines'] is List
            ? (json['lines'] as List).map((l) => l.toString()).toList()
            : const [],
      );
}
