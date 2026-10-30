import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/alerts/duty_service.dart';
import 'core/providers/core_providers.dart';
import 'core/router/app_router.dart';
import 'core/storage/prefs.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/auth_gate.dart';
import 'shared/widgets/order_alert_overlay.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Preferences need an async load, so it happens once here and the provider
  // is overridden with the result — no screen has to await it.
  final prefs = Prefs(await SharedPreferences.getInstance());

  // The buzzer's on-duty service has to be configured before anything can
  // start it, and it is cheap: this only records the notification channel and
  // task options, it does not start a service. The toggle on the Profile
  // screen does that, and it is off until a driver turns it on.
  DutyService.configure();

  runApp(
    ProviderScope(
      overrides: [prefsProvider.overrideWithValue(prefs)],
      child: const TankerApp(),
    ),
  );
}

class TankerApp extends ConsumerWidget {
  const TankerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // select() so flipping the theme does not rebuild on unrelated
    // preference writes.
    final isDark = ref.watch(prefsProvider.select((p) => p.isDarkMode));

    return MaterialApp(
      title: 'Tanker',
      debugShowCheckedModeBanner: false,
      theme: AppThemeData.lightTheme,
      darkTheme: AppThemeData.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.system,
      // AuthGate is the home rather than a named route, so session state
      // decides what is on screen and no stale shell is left on the stack.
      home: const AuthGate(),
      onGenerateRoute: AppRouter.generate,
      // The buzzer's banner is mounted here rather than inside a screen, so
      // it draws above whatever route is on top — the recipient is usually
      // deep in a pushed screen when a new order arrives, and a banner in the
      // shell would be hidden exactly then. It renders nothing unless an
      // order is actually waiting.
      navigatorKey: AppRouter.navigatorKey,
      builder: (_, child) => OrderAlertOverlay(child: child ?? const SizedBox.shrink()),
    );
  }
}
