import '../../domain/auth_user.dart';

/// Where the app is with respect to being signed in. Sealed, so the splash
/// screen cannot forget to handle "still checking".
sealed class SessionState {
  const SessionState();
}

/// Startup: a token may be on the device, and we are asking the panel whether
/// it is still good.
final class SessionChecking extends SessionState {
  const SessionChecking();
}

final class SessionSignedOut extends SessionState {
  const SessionSignedOut({this.message});

  /// Set when the session ended on its own — an expired refresh token, or an
  /// account the owner deactivated — so the login screen can say why.
  final String? message;
}

final class SessionSignedIn extends SessionState {
  const SessionSignedIn(this.user);

  final AuthUser user;
}
