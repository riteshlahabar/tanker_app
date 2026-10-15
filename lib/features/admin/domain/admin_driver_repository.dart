import '../../../core/network/api_result.dart';
import '../../../shared/models/paginated.dart';
import 'admin_driver.dart';
import 'entity_list_filter.dart';

/// Talks to `/api/admin/drivers/*`.
abstract interface class AdminDriverRepository {
  Future<ApiResult<Paginated<AdminDriver>>> list(EntityListFilter filter, {int page = 1});

  Future<ApiResult<AdminDriver>> create(Map<String, dynamic> fields);

  Future<ApiResult<AdminDriver>> update(int id, Map<String, dynamic> fields);

  Future<ApiResult<String>> delete(int id);
}
