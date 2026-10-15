import '../../../core/network/api_result.dart';
import '../../../shared/models/paginated.dart';
import 'admin_tanker.dart';
import 'entity_list_filter.dart';

/// Talks to `/api/admin/tankers/*`.
abstract interface class AdminTankerRepository {
  Future<ApiResult<Paginated<AdminTanker>>> list(EntityListFilter filter, {int page = 1, int? perPage});

  Future<ApiResult<AdminTanker>> create(Map<String, dynamic> fields);

  Future<ApiResult<AdminTanker>> update(int id, Map<String, dynamic> fields);

  Future<ApiResult<String>> delete(int id);

  /// Tankers free to assign, plus the one already held by [keepTankerId] so
  /// an edit form can still show the current selection — there is no
  /// "assignable" API, so this filters the ordinary list client-side.
  Future<ApiResult<List<AdminTanker>>> unassigned({int? keepTankerId});
}
