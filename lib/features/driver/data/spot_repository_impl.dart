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

}
