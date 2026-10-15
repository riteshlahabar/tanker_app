import 'package:intl/intl.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../shared/utils/json_read.dart';
import '../domain/driver_earnings.dart';
import '../domain/driver_repository.dart';
import '../domain/driver_summary.dart';

class DriverRepositoryImpl implements DriverRepository {
  const DriverRepositoryImpl({required ApiClient client}) : _client = client;

  final ApiClient _client;

  static final _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Future<ApiResult<DriverSummary>> summary() => _client.get<DriverSummary>(
        '/driver/summary',
        parse: (data) => DriverSummary.fromJson(JsonRead.asMap(data)),
      );

  @override
  Future<ApiResult<DriverEarnings>> earnings({DateTime? from, DateTime? to}) => _client.get<DriverEarnings>(
        '/driver/earnings',
        query: {
          if (from != null) 'from': _dateFormat.format(from),
          if (to != null) 'to': _dateFormat.format(to),
        },
        parse: (data) => DriverEarnings.fromJson(JsonRead.asMap(data)),
      );
}
