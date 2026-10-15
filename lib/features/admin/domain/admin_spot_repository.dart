import '../../../core/network/api_result.dart';
import '../../../shared/models/paginated.dart';
import '../../../shared/models/spot.dart';
import 'entity_list_filter.dart';

/// Talks to `/api/admin/spots/*`.
abstract interface class AdminSpotRepository {
  Future<ApiResult<Paginated<Spot>>> list(EntityListFilter filter, {int page = 1});

  Future<ApiResult<Spot>> create(Map<String, dynamic> fields);

  Future<ApiResult<Spot>> update(int id, Map<String, dynamic> fields);

  Future<ApiResult<String>> delete(int id);
}
