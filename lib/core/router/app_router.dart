import 'package:flutter/material.dart';

import '../../features/admin/presentation/screens/admin_shell.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/customer/presentation/screens/customer_shell.dart';
import '../../features/driver/presentation/screens/driver_shell.dart';
import '../../shared/models/user_role.dart';
import 'routes.dart';

/// Resolves a route name to a screen for the one root navigator.
///
/// Only the login screen and the three shells are root routes; every detail
/// screen is pushed on top of a shell, which is what keeps the hardware back
/// button returning to the screen immediately behind it.
class AppRouter {
  AppRouter._();

  static Route<dynamic> generate(RouteSettings settings) {
    final builder = switch (settings.name) {
      Routes.login => (BuildContext _) => const LoginScreen(),
      Routes.customerShell => (BuildContext _) => const CustomerShell(),
      Routes.driverShell => (BuildContext _) => const DriverShell(),
      Routes.adminShell => (BuildContext _) => const AdminShell(),
      _ => (BuildContext _) => const LoginScreen(),
    };

    return MaterialPageRoute<dynamic>(builder: builder, settings: settings);
  }

  /// The shell a signed-in role opens on. An unknown role is treated as no
  /// session rather than guessed at.
  static Widget shellFor(UserRole? role) => switch (role) {
        UserRole.admin => const AdminShell(),
        UserRole.driver => const DriverShell(),
        UserRole.customer => const CustomerShell(),
        null => const LoginScreen(),
      };
}
