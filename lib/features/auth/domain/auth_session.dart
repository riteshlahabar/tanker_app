import '../../../shared/utils/json_read.dart';
import 'auth_user.dart';

/// What a successful login returns: who signed in, and the token pair that
/// proves it. The panel nests these as `data.user` and `data.token`.
class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.abilities,
  });

  final AuthUser user;
  final String accessToken;
  final String refreshToken;

  /// Seconds the access token is good for — 7200 as the panel is configured.
  final int expiresIn;

  /// The role's permissions, scoped onto the token. A screen can hide an
  /// action the token could not perform anyway.
  final List<String> abilities;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final token = JsonRead.asMap(json['token']);

    return AuthSession(
      user: AuthUser.fromJson(JsonRead.asMap(json['user'])),
      accessToken: JsonRead.asString(token['access_token']),
      refreshToken: JsonRead.asString(token['refresh_token']),
      expiresIn: JsonRead.asInt(token['expires_in']),
      abilities: token['abilities'] is List
          ? (token['abilities'] as List).map((a) => a.toString()).toList(growable: false)
          : const [],
    );
  }

  bool can(String ability) => abilities.contains(ability);
}
