import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import 'auth_providers.dart';
import 'session_state.dart';

part 'session_controller.g.dart';

/// Who is signed in, for the whole app. The router reads this to decide which
/// shell to show, and nothing else keeps its own copy.
@Riverpod(keepAlive: true)
class SessionController extends _$SessionController {
  @override
  SessionState build() {
    // A refresh that could not be rescued ends the session wherever the app
    // happens to be, so the listener lives here rather than on a screen.
    final subscription = ref.watch(sessionExpiryBusProvider).stream.listen(
          (_) => state = const SessionSignedOut(
            message: 'Your session has expired. Please sign in again.',
          ),
        );

    ref.onDispose(subscription.cancel);

    unawaited(_restore());

    return const SessionChecking();
  }

  /// Confirms a stored token with the panel rather than trusting it. An
  /// account the owner switched off is rejected by the `active` middleware, so
  /// this is also what stops a deactivated user carrying on offline.
  Future<void> _restore() async {
    final hasToken = await ref.read(secureStorageProvider).hasSession();

    if (!hasToken) {
      state = const SessionSignedOut();

      return;
    }

    final result = await ref.read(authRepositoryProvider).me();

    state = result.when(
      success: SessionSignedIn.new,
      error: (failure) => SessionSignedOut(message: failure.message),
    );
  }

  /// Called by the login controller once credentials are accepted.
  void signedIn(SessionSignedIn session) => state = session;

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).logout();

    state = const SessionSignedOut();
  }
}
