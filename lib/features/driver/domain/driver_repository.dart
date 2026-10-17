import '../../../core/network/api_result.dart';
import 'driver_summary.dart';

/// Talks to `/api/driver/summary`.
///
/// `GET /api/driver/salary` exists on the panel and is tested there, but no
/// screen reads it any more: the 5th tab became Expenses, and the salary
/// itself reaches Profile through `/auth/me`. The method was dropped rather
/// than left as dead code.
abstract interface class DriverRepository {
  Future<ApiResult<DriverSummary>> summary();
}
