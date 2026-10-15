/// Where the Laravel panel lives, and the knobs that go with it.
///
/// `--dart-define=TANKER_API_URL=https://...` overrides the base URL at build
/// time, so a release build never carries a developer's local address.
class AppConfig {
  AppConfig._();

  /// 10.0.2.2 is the host machine as seen from the Android emulator; a device
  /// on the same wi-fi needs the machine's LAN address instead.
  static const String baseUrl = String.fromEnvironment(
    'TANKER_API_URL',
    defaultValue: 'https://wtms.turnkeyinfotech.live/api',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  /// Sent as `device_name` when issuing a token, so the owner can revoke one
  /// device without signing every other one out.
  static const String deviceName = 'tanker-app';

  static const int defaultPageSize = 20;
}
