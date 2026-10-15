// ignore_for_file: prefer_initializing_formals
//
// The fields are private and Dart forbids a named parameter starting with an
// underscore, so an initializing formal is not available here.

import 'package:dio/dio.dart';

import '../../config/app_config.dart';
import '../../storage/secure_storage.dart';

/// Puts the access token on every request, and rescues one 401 by refreshing.
///
/// The access token is deliberately short-lived, so an expiry mid-session is
/// normal rather than exceptional: the failed call is retried once with a
/// fresh token and the user never sees it. A refresh that itself fails clears
/// the session, which is what sends the app back to the login screen.
class AuthInterceptor extends Interceptor {
  const AuthInterceptor({
    required SecureStorage storage,
    required Dio refreshClient,
    required Future<void> Function() onSessionLost,
  })  : _storage = storage,
        _refreshClient = refreshClient,
        _onSessionLost = onSessionLost;

  final SecureStorage _storage;

  /// A bare client, so refreshing cannot recurse back through this
  /// interceptor and loop.
  final Dio _refreshClient;

  final Future<void> Function() _onSessionLost;

  /// Endpoints that must not carry an access token.
  static const _unauthenticated = {'/auth/login', '/auth/refresh'};

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!_unauthenticated.any(options.path.endsWith)) {
      final token = await _storage.accessToken();

      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    options.headers['Accept'] = 'application/json';

    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final isExpired = err.response?.statusCode == 401 &&
        !_unauthenticated.any(err.requestOptions.path.endsWith) &&
        err.requestOptions.extra['retried'] != true;

    if (!isExpired) return handler.next(err);

    final refreshed = await _refresh();

    if (!refreshed) {
      await _onSessionLost();

      return handler.next(err);
    }

    try {
      handler.resolve(await _retry(err.requestOptions));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  /// Swaps the expired pair for a fresh one. `/auth/refresh` is the one
  /// endpoint that takes the refresh token, which is why it goes out on the
  /// bare client with an explicit header.
  ///
  /// Two things about the panel's side of this matter here. It answers with
  /// `data.token.{access_token, refresh_token}`, and issuing a pair *revokes
  /// the device's previous pair* — so the new refresh token has to be stored
  /// as well, or the next refresh presents a token the panel has deleted.
  /// `device_name` must match the one login used, or a stale pair is left
  /// behind under the other name.
  Future<bool> _refresh() async {
    final refreshToken = await _storage.refreshToken();

    if (refreshToken == null) return false;

    try {
      final response = await _refreshClient.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'device_name': AppConfig.deviceName},
        options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
      );

      final data = response.data?['data'];
      final token = data is Map<String, dynamic> ? data['token'] : null;

      if (token is! Map<String, dynamic>) return false;

      final access = token['access_token'];
      final refresh = token['refresh_token'];

      if (access is! String || access.isEmpty) return false;

      if (refresh is String && refresh.isNotEmpty) {
        await _storage.saveTokens(accessToken: access, refreshToken: refresh);
      } else {
        await _storage.saveAccessToken(access);
      }

      return true;
    } on DioException {
      return false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions options) async {
    final token = await _storage.accessToken();

    return _refreshClient.fetch<dynamic>(
      options
        ..headers['Authorization'] = 'Bearer $token'
        ..extra['retried'] = true,
    );
  }

  /// A client that talks to the same panel but carries no interceptors.
  static Dio bareClient() => Dio(
        BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: AppConfig.connectTimeout,
          receiveTimeout: AppConfig.receiveTimeout,
          headers: const {'Accept': 'application/json'},
        ),
      );
}
