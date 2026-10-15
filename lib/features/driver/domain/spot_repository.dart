import '../../../core/network/api_result.dart';
import '../../../shared/models/spot.dart';

/// Talks to `/api/spots` and `/api/spots/nearby`.
abstract interface class SpotRepository {
  Future<ApiResult<List<Spot>>> usable();

  Future<ApiResult<List<Spot>>> nearby({
    required double latitude,
    required double longitude,
    int limit = 10,
  });
}
