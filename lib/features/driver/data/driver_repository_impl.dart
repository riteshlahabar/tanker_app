import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../shared/utils/json_read.dart';
import '../domain/driver_repository.dart';
import '../domain/driver_summary.dart';

class DriverRepositoryImpl implements DriverRepository {
  const DriverRepositoryImpl({required ApiClient client}) : _client = client;

  final ApiClient _client;

  @override
  Future<ApiResult<DriverSummary>> summary() => _client.get<DriverSummary>(
        '/driver/summary',
        parse: (data) => DriverSummary.fromJson(JsonRead.asMap(data)),
      );
}
