import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../shared/utils/json_read.dart';
import '../domain/admin_dashboard.dart';
import '../domain/admin_dashboard_repository.dart';

class AdminDashboardRepositoryImpl implements AdminDashboardRepository {
  const AdminDashboardRepositoryImpl({required ApiClient client}) : _client = client;

  final ApiClient _client;

  @override
  Future<ApiResult<AdminDashboard>> summary() => _client.get<AdminDashboard>(
        '/admin/dashboard',
        parse: (data) => AdminDashboard.fromJson(JsonRead.asMap(data)),
      );
}
