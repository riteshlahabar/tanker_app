import '../../../core/network/api_result.dart';
import 'admin_report_definition.dart';
import 'admin_report_filter.dart';
import 'admin_report_result.dart';

/// Talks to `/api/admin/reports/*`.
abstract interface class AdminReportRepository {
  Future<ApiResult<List<AdminReportDefinition>>> index();

  Future<ApiResult<AdminReportResult>> show(String key, AdminReportFilter filter);
}
