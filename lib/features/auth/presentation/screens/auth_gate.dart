import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_router.dart';
import '../providers/session_controller.dart';
import '../providers/session_state.dart';
import 'login_screen.dart';
import 'splash_screen.dart';

/// The app's home: whichever of splash, login or a role shell the session
/// calls for.
///
/// Routing on session state rather than pushing after login means an expired
/// token drops the user back to login from wherever they are, and there is no
/// stale shell left on the stack behind it.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);

    return switch (session) {
      SessionChecking() => const SplashScreen(),
      SessionSignedOut(message: final notice) => LoginScreen(notice: notice),
      SessionSignedIn(user: final user) => AppRouter.shellFor(user.role),
    };
  }
}
