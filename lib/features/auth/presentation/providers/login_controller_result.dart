import '../../domain/auth_session.dart';

/// What a submit attempt came to. Returned to the screen so it can show a
/// toast, without the screen having to re-read the controller's state.
class LoginOutcome {
  const LoginOutcome.signedIn(this.session)
      : accepted = true,
        wasIgnored = false;

  const LoginOutcome.refused()
      : session = null,
        accepted = false,
        wasIgnored = false;

  /// A second tap while the first is still in flight.
  const LoginOutcome.ignored()
      : session = null,
        accepted = false,
        wasIgnored = true;

  final AuthSession? session;
  final bool accepted;
  final bool wasIgnored;
}
