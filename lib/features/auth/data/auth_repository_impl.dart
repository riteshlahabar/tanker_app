import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../shared/utils/json_read.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_session.dart';
import '../domain/auth_user.dart';

/// Talks to `/api/auth/*` and keeps the token pair in the keystore.
///
/// Storing the tokens is this class's job rather than the provider's, so a
/// successful login is never half-applied — the session is written before the
/// caller is told it worked.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required ApiClient client,
    required SecureStorage storage,
  })  : _client = client,
        _storage = storage;

  final ApiClient _client;
  final SecureStorage _storage;

  @override
  Future<ApiResult<AuthSession>> login({
    required String username,
    required String password,
  }) async {
    final result = await _client.post<AuthSession>(
      '/auth/login',
      body: {
        'username': username,
        'password': password,
        // Must match what refresh sends, or the panel revokes a different
        // device's pair and leaves this one stale.
        'device_name': AppConfig.deviceName,
      },
      parse: (data) => AuthSession.fromJson(JsonRead.asMap(data)),
    );

    final session = result.valueOrNull;

    if (session != null) {
      await _storage.saveTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        role: session.user.role?.value,
      );
    }

    return result;
  }

  @override
  Future<ApiResult<AuthUser>> me() => _client.get<AuthUser>(
        '/auth/me',
        parse: (data) => AuthUser.fromJson(JsonRead.asMap(data)),
      );

  @override
  Future<ApiResult<String>> logout() async {
    final result = await _client.command('/auth/logout');

    // The local session goes either way: if the token was already dead the
    // call fails, and leaving it on the device would strand the user.
    await _storage.clear();

    return result;
  }

  @override
  Future<ApiResult<String>> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) =>
      _client.command(
        '/auth/change-password',
        body: {
          'current_password': currentPassword,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

  @override
  Future<ApiResult<AuthUser>> updateProfile({
    required String firstName,
    String? lastName,
    String? address,
  }) =>
      _client.put<AuthUser>(
        '/auth/profile',
        body: {
          'first_name': firstName,
          'last_name': ?lastName,
          'address': ?address,
        },
        parse: (data) => AuthUser.fromJson(JsonRead.asMap(data)),
      );
}
