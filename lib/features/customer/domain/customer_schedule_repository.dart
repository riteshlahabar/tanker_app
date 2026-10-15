import '../../../core/network/api_result.dart';
import 'my_schedule.dart';

/// Talks to `/api/customer/schedule/*`.
abstract interface class CustomerScheduleRepository {
  Future<ApiResult<MySchedule>> mySchedule();

  Future<ApiResult<String>> skip(DateTime date, String? reason);

  Future<ApiResult<String>> restore(DateTime date);
}
