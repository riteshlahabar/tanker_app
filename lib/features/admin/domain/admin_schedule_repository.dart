import '../../../core/network/api_result.dart';
import '../../../shared/models/paginated.dart';
import 'admin_generate_result.dart';
import 'admin_schedule.dart';
import 'admin_schedule_detail.dart';
import 'admin_schedule_filter.dart';

/// Talks to `/api/admin/schedules/*`.
abstract interface class AdminScheduleRepository {
  Future<ApiResult<Paginated<AdminSchedule>>> list(AdminScheduleFilter filter, {int page = 1});

  Future<ApiResult<AdminScheduleDetail>> show(int id);

  Future<ApiResult<AdminSchedule>> create(Map<String, dynamic> fields);

  Future<ApiResult<AdminSchedule>> update(int id, Map<String, dynamic> fields);

  Future<ApiResult<String>> delete(int id);

  Future<ApiResult<AdminGenerateResult>> generate({DateTime? date, bool dryRun = false});

  Future<ApiResult<String>> skip(int scheduleId, DateTime date, String? reason);

  Future<ApiResult<String>> restore(int scheduleId, DateTime date);
}
