import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../shared/models/paginated.dart';
import '../../../shared/utils/json_read.dart';
import '../domain/admin_tanker.dart';
import '../domain/admin_tanker_repository.dart';
import '../domain/entity_list_filter.dart';

class AdminTankerRepositoryImpl implements AdminTankerRepository {
  const AdminTankerRepositoryImpl({required ApiClient client}) : _client = client;

  final ApiClient _client;

  @override
  Future<ApiResult<Paginated<AdminTanker>>> list(
    EntityListFilter filter, {
    int page = 1,
    int? perPage,
  }) =>
      _client.list<AdminTanker>(
        '/admin/tankers',
        query: {
          'page': page,
          'per_page': ?perPage,
          if (filter.search != null && filter.search!.isNotEmpty) 'search': filter.search,
          'status': ?filter.status,
        },
        parse: AdminTanker.fromJson,
      );

  @override
  Future<ApiResult<AdminTanker>> create(Map<String, dynamic> fields) => _client.post<AdminTanker>(
        '/admin/tankers',
        body: fields,
        parse: (data) => AdminTanker.fromJson(JsonRead.asMap(data)),
      );

  @override
  Future<ApiResult<AdminTanker>> update(int id, Map<String, dynamic> fields) =>
      _client.put<AdminTanker>(
        '/admin/tankers/$id',
        body: fields,
        parse: (data) => AdminTanker.fromJson(JsonRead.asMap(data)),
      );

  @override
  Future<ApiResult<String>> delete(int id) =>
      _client.delete<String>('/admin/tankers/$id', parse: (_) => '');

  @override
  Future<ApiResult<List<AdminTanker>>> unassigned({int? keepTankerId}) async {
    final result = await list(const EntityListFilter(status: true), page: 1, perPage: 100);

    return result.map(
      (page) => page.items
          .where((tanker) => tanker.currentDriver == null || tanker.id == keepTankerId)
          .toList(),
    );
  }
}
