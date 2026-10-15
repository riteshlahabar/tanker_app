import '../../../core/network/api_result.dart';
import 'admin_dashboard.dart';

/// Talks to `/api/admin/dashboard`.
abstract interface class AdminDashboardRepository {
  Future<ApiResult<AdminDashboard>> summary();
}
