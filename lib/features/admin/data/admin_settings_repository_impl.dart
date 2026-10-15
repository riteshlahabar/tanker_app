import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../shared/utils/json_read.dart';
import '../domain/admin_settings_repository.dart';

class AdminSettingsRepositoryImpl implements AdminSettingsRepository {
  const AdminSettingsRepositoryImpl({required ApiClient client}) : _client = client;

  final ApiClient _client;

  @override
  Future<ApiResult<Map<String, String?>>> show() => _client.get<Map<String, String?>>(
        '/admin/settings',
        parse: (data) => _asStringMap(data),
      );

  @override
  Future<ApiResult<Map<String, String?>>> update(Map<String, String> values) =>
      _client.put<Map<String, String?>>(
        '/admin/settings',
        body: values,
        parse: (data) => _asStringMap(data),
      );

  Map<String, String?> _asStringMap(Object? data) =>
      JsonRead.asMap(data).map((key, value) => MapEntry(key, JsonRead.asStringOrNull(value)));
}
