import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/auth_session.dart';
import 'auth_providers.dart';
import 'login_controller_result.dart';
import 'login_state.dart';
import 'session_controller.dart';
import 'session_state.dart';

part 'login_controller.g.dart';

/// Drives the login form: one submit, one piece of state. The screen holds no
/// logic of its own beyond collecting the two fields.
@riverpod
class LoginController extends _$LoginController {
  @override
  LoginState build() => const LoginState();

  void togglePasswordVisibility() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  /// Clears a stale error as soon as the user edits either field.
  void fieldChanged() {
    if (state.failure != null) state = state.copyWith(clearFailure: true);
  }

  /// Signs in and, on success, hands the session to [SessionController] — the
  /// router reacts to that rather than this screen navigating itself.
  Future<LoginOutcome> submit({
    required String username,
    required String password,
  }) async {
    if (state.submitting) return const LoginOutcome.ignored();

    state = state.copyWith(submitting: true, clearFailure: true);

    final result = await ref.read(authRepositoryProvider).login(
          username: username.trim(),
          password: password,
        );

    return result.when(
      success: (AuthSession session) {
        state = state.copyWith(submitting: false);
        ref.read(sessionControllerProvider.notifier).signedIn(SessionSignedIn(session.user));

        return LoginOutcome.signedIn(session);
      },
      error: (failure) {
        state = state.copyWith(submitting: false, failure: failure);

        return const LoginOutcome.refused();
      },
    );
  }
}
