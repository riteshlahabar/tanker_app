import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The token pair, in the platform keystore rather than shared preferences.
///
/// Sanctum hands out a short-lived access token plus a refresh token; both are
/// held here and nowhere else, so no other layer can read or log them.
class SecureStorage {
  const SecureStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _accessKey = 'tanker.access_token';
  static const _refreshKey = 'tanker.refresh_token';
  static const _roleKey = 'tanker.role';

  Future<String?> accessToken() => _storage.read(key: _accessKey);

  Future<String?> refreshToken() => _storage.read(key: _refreshKey);

  /// The role decides which shell the app opens on, so it is kept alongside
  /// the tokens and read once at startup.
  Future<String?> role() => _storage.read(key: _roleKey);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? role,
  }) async {
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);

    if (role != null) {
      await _storage.write(key: _roleKey, value: role);
    }
  }

  /// Only the access token moves on a refresh; the refresh token stays put.
  Future<void> saveAccessToken(String accessToken) =>
      _storage.write(key: _accessKey, value: accessToken);

  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _roleKey);
  }

  Future<bool> hasSession() async => (await accessToken()) != null;
}
