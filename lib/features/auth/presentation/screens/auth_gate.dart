import 'dart:async';

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
///
/// The splash is held for a **fixed five seconds** at the owner's request,
/// whatever the session check does: the token check usually answers in a few
/// hundred milliseconds, so without a floor the brand would flash past. The
/// two run side by side rather than one after the other, so the wait is five
/// seconds in total, not five plus the network.
class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  /// How long the logo stays up before the app will move on.
  static const Duration splashFor = Duration(seconds: 5);

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool _splashDone = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(AuthGate.splashFor, () {
      if (mounted) setState(() => _splashDone = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);

    if (!_splashDone || session is SessionChecking) return const SplashScreen();

    return switch (session) {
      SessionSignedOut(message: final notice) => LoginScreen(notice: notice),
      SessionSignedIn(user: final user) => AppRouter.shellFor(user.role),
      _ => const SplashScreen(),
    };
  }
}
