import 'package:intl/intl.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../shared/models/paginated.dart';
import '../../../shared/utils/json_read.dart';
import '../domain/admin_generate_result.dart';
import '../domain/admin_schedule.dart';
import '../domain/admin_schedule_detail.dart';
import '../domain/admin_schedule_filter.dart';
import '../domain/admin_schedule_repository.dart';

class AdminScheduleRepositoryImpl implements AdminScheduleRepository {
  const AdminScheduleRepositoryImpl({required ApiClient client}) : _client = client;

  final ApiClient _client;

  static final _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Future<ApiResult<Paginated<AdminSchedule>>> list(AdminScheduleFilter filter, {int page = 1}) =>
      _client.list<AdminSchedule>(
        '/admin/schedules',
        query: {
          'page': page,
          'customer_id': ?filter.customerId,
          'status': ?filter.status,
          'paused': ?filter.paused,
          if (filter.search != null && filter.search!.isNotEmpty) 'search': filter.search,
        },
        parse: AdminSchedule.fromJson,
      );

  @override
  Future<ApiResult<AdminScheduleDetail>> show(int id) => _client.get<AdminScheduleDetail>(
        '/admin/schedules/$id',
        parse: (data) => AdminScheduleDetail.fromJson(JsonRead.asMap(data)),
      );

  @override
  Future<ApiResult<AdminSchedule>> create(Map<String, dynamic> fields) =>
      _client.post<AdminSchedule>(
        '/admin/schedules',
        body: fields,
        parse: (data) => AdminSchedule.fromJson(JsonRead.asMap(data)),
      );

  @override
  Future<ApiResult<AdminSchedule>> update(int id, Map<String, dynamic> fields) =>
      _client.put<AdminSchedule>(
        '/admin/schedules/$id',
        body: fields,
        parse: (data) => AdminSchedule.fromJson(JsonRead.asMap(data)),
      );

  @override
  Future<ApiResult<String>> delete(int id) =>
      _client.delete<String>('/admin/schedules/$id', parse: (_) => '');

  @override
  Future<ApiResult<AdminGenerateResult>> generate({DateTime? date, bool dryRun = false}) {
    final formattedDate = date == null ? null : _dateFormat.format(date);

    return _client.post<AdminGenerateResult>(
      '/admin/schedules/generate',
      body: {
        'date': ?formattedDate,
        'dry_run': dryRun,
      },
      parse: (data) => AdminGenerateResult.fromJson(JsonRead.asMap(data)),
    );
  }

  @override
  Future<ApiResult<String>> skip(int scheduleId, DateTime date, String? reason) => _client.command(
        '/admin/schedules/$scheduleId/skips',
        body: {
          'date': _dateFormat.format(date),
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
      );

  @override
  Future<ApiResult<String>> restore(int scheduleId, DateTime date) => _client.delete<String>(
        '/admin/schedules/$scheduleId/skips/${_dateFormat.format(date)}',
        parse: (_) => '',
      );
}
