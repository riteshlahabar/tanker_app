import 'package:intl/intl.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../shared/utils/json_read.dart';
import '../domain/customer_schedule_repository.dart';
import '../domain/my_schedule.dart';

class CustomerScheduleRepositoryImpl implements CustomerScheduleRepository {
  const CustomerScheduleRepositoryImpl({required ApiClient client}) : _client = client;

  final ApiClient _client;

  static final _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Future<ApiResult<MySchedule>> mySchedule() => _client.get<MySchedule>(
        '/customer/schedule',
        parse: (data) => MySchedule.fromJson(JsonRead.asMap(data)),
      );

  @override
  Future<ApiResult<String>> skip(DateTime date, String? reason) => _client.command(
        '/customer/schedule/skips',
        body: {
          'date': _dateFormat.format(date),
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
      );

  @override
  Future<ApiResult<String>> restore(DateTime date) => _client.delete<String>(
        '/customer/schedule/skips/${_dateFormat.format(date)}',
        parse: (_) => '',
      );
}
