import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../shared/models/spot.dart';
import '../../../shared/utils/json_read.dart';
import '../domain/spot_repository.dart';

class SpotRepositoryImpl implements SpotRepository {
  const SpotRepositoryImpl({required ApiClient client}) : _client = client;

  final ApiClient _client;

  @override
  Future<ApiResult<List<Spot>>> usable() => _client.get<List<Spot>>(
        '/spots',
        parse: (data) => JsonRead.asMapList(data).map(Spot.fromJson).toList(),
      );

  @override
  Future<ApiResult<List<Spot>>> nearby({
    required double latitude,
    required double longitude,
    int limit = 10,
  }) =>
      _client.get<List<Spot>>(
        '/spots/nearby',
        query: {'latitude': latitude, 'longitude': longitude, 'limit': limit},
        parse: (data) => JsonRead.asMapList(data).map(Spot.fromJson).toList(),
      );
}
