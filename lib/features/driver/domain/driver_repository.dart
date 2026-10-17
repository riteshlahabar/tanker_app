import '../../../core/network/api_result.dart';
import 'driver_salary.dart';
import 'driver_summary.dart';

/// Talks to `/api/driver/summary` and `/api/driver/salary`.
abstract interface class DriverRepository {
  Future<ApiResult<DriverSummary>> summary();

  Future<ApiResult<DriverSalary>> salary({DateTime? from, DateTime? to});
}
