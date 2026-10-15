import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../shared/models/paginated.dart';
import '../../../shared/models/spot.dart';
import '../../../shared/utils/json_read.dart';
import '../domain/admin_spot_repository.dart';
import '../domain/entity_list_filter.dart';

class AdminSpotRepositoryImpl implements AdminSpotRepository {
  const AdminSpotRepositoryImpl({required ApiClient client}) : _client = client;

  final ApiClient _client;

  @override
  Future<ApiResult<Paginated<Spot>>> list(EntityListFilter filter, {int page = 1}) =>
      _client.list<Spot>(
        '/admin/spots',
        query: {
          'page': page,
          if (filter.search != null && filter.search!.isNotEmpty) 'search': filter.search,
          'status': ?filter.status,
        },
        parse: Spot.fromJson,
      );

  @override
  Future<ApiResult<Spot>> create(Map<String, dynamic> fields) => _client.post<Spot>(
        '/admin/spots',
        body: fields,
        parse: (data) => Spot.fromJson(JsonRead.asMap(data)),
      );

  @override
  Future<ApiResult<Spot>> update(int id, Map<String, dynamic> fields) => _client.put<Spot>(
        '/admin/spots/$id',
        body: fields,
        parse: (data) => Spot.fromJson(JsonRead.asMap(data)),
      );

  @override
  Future<ApiResult<String>> delete(int id) =>
      _client.delete<String>('/admin/spots/$id', parse: (_) => '');
}
