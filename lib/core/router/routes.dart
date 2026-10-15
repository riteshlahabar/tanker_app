/// Named routes, in one place so a typo is a compile error at the call site
/// rather than a blank screen.
class Routes {
  Routes._();

  static const String splash = '/';
  static const String login = '/login';

  static const String customerShell = '/customer';
  static const String driverShell = '/driver';
  static const String adminShell = '/admin';
}
