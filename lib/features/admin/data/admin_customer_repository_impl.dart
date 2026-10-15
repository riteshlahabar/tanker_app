import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../shared/models/paginated.dart';
import '../../../shared/utils/json_read.dart';
import '../domain/admin_customer.dart';
import '../domain/admin_customer_repository.dart';
import '../domain/entity_list_filter.dart';

class AdminCustomerRepositoryImpl implements AdminCustomerRepository {
  const AdminCustomerRepositoryImpl({required ApiClient client}) : _client = client;

  final ApiClient _client;

  @override
  Future<ApiResult<Paginated<AdminCustomer>>> list(EntityListFilter filter, {int page = 1}) =>
      _client.list<AdminCustomer>(
        '/admin/customers',
        query: {
          'page': page,
          if (filter.search != null && filter.search!.isNotEmpty) 'search': filter.search,
          'status': ?filter.status,
        },
        parse: AdminCustomer.fromJson,
      );

  @override
  Future<ApiResult<AdminCustomer>> create(Map<String, dynamic> fields) =>
      _client.post<AdminCustomer>(
        '/admin/customers',
        body: fields,
        parse: (data) => AdminCustomer.fromJson(JsonRead.asMap(data)),
      );

  @override
  Future<ApiResult<AdminCustomer>> update(int id, Map<String, dynamic> fields) =>
      _client.put<AdminCustomer>(
        '/admin/customers/$id',
        body: fields,
        parse: (data) => AdminCustomer.fromJson(JsonRead.asMap(data)),
      );

  @override
  Future<ApiResult<String>> delete(int id) =>
      _client.delete<String>('/admin/customers/$id', parse: (_) => '');
}
