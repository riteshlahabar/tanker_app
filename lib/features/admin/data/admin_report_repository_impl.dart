import 'package:intl/intl.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../shared/utils/json_read.dart';
import '../domain/admin_report_definition.dart';
import '../domain/admin_report_filter.dart';
import '../domain/admin_report_repository.dart';
import '../domain/admin_report_result.dart';

class AdminReportRepositoryImpl implements AdminReportRepository {
  const AdminReportRepositoryImpl({required ApiClient client}) : _client = client;

  final ApiClient _client;

  static final _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Future<ApiResult<List<AdminReportDefinition>>> index() => _client.get<List<AdminReportDefinition>>(
        '/admin/reports',
        parse: (data) => JsonRead.asMapList(data).map(AdminReportDefinition.fromJson).toList(),
      );

  @override
  Future<ApiResult<AdminReportResult>> show(String key, AdminReportFilter filter) {
    final from = filter.from == null ? null : _dateFormat.format(filter.from!);
    final to = filter.to == null ? null : _dateFormat.format(filter.to!);

    return _client.get<AdminReportResult>(
      '/admin/reports/$key',
      query: {
        'from': ?from,
        'to': ?to,
        'driver_id': ?filter.driverId,
        'customer_id': ?filter.customerId,
        'spot_id': ?filter.spotId,
        'tanker_id': ?filter.tankerId,
        if (filter.search != null && filter.search!.isNotEmpty) 'search': filter.search,
      },
      parse: (data) => AdminReportResult.fromJson(JsonRead.asMap(data)),
    );
  }
}
