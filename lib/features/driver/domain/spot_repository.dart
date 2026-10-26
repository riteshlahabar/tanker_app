import '../../../core/network/api_result.dart';
import '../../../shared/models/spot.dart';

/// Talks to `/api/spots`.
///
/// `/api/spots/nearby` went with the coordinates it sorted by — see
/// [NearbySpotsController].
abstract interface class SpotRepository {
  Future<ApiResult<List<Spot>>> usable();
}
