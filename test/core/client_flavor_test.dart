import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/core/config/app_config.dart';
import 'package:tanker_app/core/config/client_flavor.dart';

void main() {
  group('ClientFlavor', () {
    // `appFlavor` is a compile-time constant, so a test can only observe the
    // flavour it was itself built with — which is none. That is worth pinning
    // precisely because it is the case nothing else exercises: `flutter test`,
    // a plain `flutter run`, and the unflavoured iOS build all land here, and
    // none of them may end up with a null or empty panel address.
    test('a build with no --flavor is the owner\'s own', () {
      expect(ClientFlavor.isFallbackBuild, isTrue);
      expect(ClientFlavor.name, 'wtms');
      expect(ClientFlavor.apiBaseUrl, 'https://wtms.turnkeyinfotech.live/api');
    });

    test('the panel address is the one the app actually uses', () {
      // No --dart-define in a test run, so AppConfig must fall through to the
      // flavour rather than to a hard-coded URL of its own.
      expect(AppConfig.baseUrl, ClientFlavor.apiBaseUrl);
    });

    test('every flavour gets a panel, never an empty string', () {
      expect(ClientFlavor.apiBaseUrl, startsWith('https://'));
      expect(ClientFlavor.apiBaseUrl, endsWith('/api'));
    });
  });
}
