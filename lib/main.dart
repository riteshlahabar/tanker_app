import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/providers/core_providers.dart';
import 'core/router/app_router.dart';
import 'core/storage/prefs.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Preferences need an async load, so it happens once here and the provider
  // is overridden with the result — no screen has to await it.
  final prefs = Prefs(await SharedPreferences.getInstance());

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
    );
  }
}
