import '../../../core/network/api_result.dart';

/// Talks to `/api/admin/settings`. A plain key/value map is all `all_()`
/// (the panel's own shape) is — no need for a dedicated entity class.
abstract interface class AdminSettingsRepository {
  Future<ApiResult<Map<String, String?>>> show();

  Future<ApiResult<Map<String, String?>>> update(Map<String, String> values);
}
