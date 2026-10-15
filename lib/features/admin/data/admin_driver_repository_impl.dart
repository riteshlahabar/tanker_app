import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../shared/models/paginated.dart';
import '../../../shared/utils/json_read.dart';
import '../domain/admin_driver.dart';
import '../domain/admin_driver_repository.dart';
import '../domain/entity_list_filter.dart';

class AdminDriverRepositoryImpl implements AdminDriverRepository {
  const AdminDriverRepositoryImpl({required ApiClient client}) : _client = client;

  final ApiClient _client;

  @override
  Future<ApiResult<Paginated<AdminDriver>>> list(EntityListFilter filter, {int page = 1}) =>
      _client.list<AdminDriver>(
        '/admin/drivers',
        query: {
          'page': page,
          if (filter.search != null && filter.search!.isNotEmpty) 'search': filter.search,
          'status': ?filter.status,
        },
        parse: AdminDriver.fromJson,
      );

  @override
  Future<ApiResult<AdminDriver>> create(Map<String, dynamic> fields) => _client.post<AdminDriver>(
        '/admin/drivers',
        body: fields,
        parse: (data) => AdminDriver.fromJson(JsonRead.asMap(data)),
      );

  @override
  Future<ApiResult<AdminDriver>> update(int id, Map<String, dynamic> fields) =>
      _client.put<AdminDriver>(
        '/admin/drivers/$id',
        body: fields,
        parse: (data) => AdminDriver.fromJson(JsonRead.asMap(data)),
      );

  @override
  Future<ApiResult<String>> delete(int id) =>
      _client.delete<String>('/admin/drivers/$id', parse: (_) => '');
}
