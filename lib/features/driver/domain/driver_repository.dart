import '../../../core/network/api_result.dart';
import 'driver_earnings.dart';
import 'driver_summary.dart';

/// Talks to `/api/driver/summary` and `/api/driver/earnings`.
abstract interface class DriverRepository {
  Future<ApiResult<DriverSummary>> summary();

  Future<ApiResult<DriverEarnings>> earnings({DateTime? from, DateTime? to});
}
