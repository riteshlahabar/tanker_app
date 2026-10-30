import 'client_flavor.dart';

/// Where the Laravel panel lives, and the knobs that go with it.
class AppConfig {
  AppConfig._();

  /// A developer's own address, for pointing a build at a local panel:
  /// `--dart-define=TANKER_API_URL=http://10.0.2.2:8000/api`. 10.0.2.2 is the
  /// host machine as seen from the Android emulator; a device on the same
  /// wi-fi needs the machine's LAN address instead.
  ///
  /// Empty unless given, so it cannot be mistaken for a configured value.
  static const String _override = String.fromEnvironment('TANKER_API_URL');

  /// Which panel this build talks to.
  ///
  /// The `--dart-define` wins when it is given, so a developer can aim a
  /// flavoured build at their own machine without editing anything. Otherwise
  /// it is the client's own panel, from the `--flavor` the build was made
  /// with — see [ClientFlavor], and add a client in
  /// `android/app/build.gradle.kts`.
  static String get baseUrl => _override.isEmpty ? ClientFlavor.apiBaseUrl : _override;

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  /// Sent as `device_name` when issuing a token, so the owner can revoke one
  /// device without signing every other one out.
  static const String deviceName = 'tanker-app';

  static const int defaultPageSize = 20;
}
