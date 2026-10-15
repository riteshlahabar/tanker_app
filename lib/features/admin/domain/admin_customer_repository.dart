import '../../../core/network/api_result.dart';
import '../../../shared/models/paginated.dart';
import 'admin_customer.dart';
import 'entity_list_filter.dart';

/// Talks to `/api/admin/customers/*`.
abstract interface class AdminCustomerRepository {
  Future<ApiResult<Paginated<AdminCustomer>>> list(EntityListFilter filter, {int page = 1});

  Future<ApiResult<AdminCustomer>> create(Map<String, dynamic> fields);

  Future<ApiResult<AdminCustomer>> update(int id, Map<String, dynamic> fields);

  Future<ApiResult<String>> delete(int id);
}
