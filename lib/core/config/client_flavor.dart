import 'package:flutter/services.dart' show appFlavor;

/// Which client this build is for.
///
/// **Adding a client is one file: `android/app/build.gradle.kts`.** Add a
/// `create("<name>")` block there with its `applicationId` and `app_name`, and
/// this file needs no change at all — the panel's address is derived from the
/// flavour name:
///
/// ```
///   <flavour>  ->  https://<flavour>.turnkeyinfotech.live/api
/// ```
///
/// which is how both existing clients are already deployed (`wtms` and
/// `tademo`). Derived rather than listed on purpose: a second list in Dart
/// would be a second place to forget, and the failure it produces — an app
/// that builds happily and then talks to another client's panel — is the worst
/// kind there is.
///
/// A client whose panel is **not** at that address is the one case that needs
/// this file: put it in [_offPattern], which is checked first.
class ClientFlavor {
  ClientFlavor._();

  /// The flavour a build with no `--flavor` is treated as: the owner's own.
  ///
  /// `appFlavor` is null for `flutter test`, for a plain `flutter run`, and
  /// for the iOS build, which has no flavours of its own yet. None of those
  /// should be a crash or a blank URL.
  static const String fallback = 'wtms';

  /// Clients whose panel is not at `<flavour>.turnkeyinfotech.live`.
  static const Map<String, String> _offPattern = {
    // 'someclient': 'https://panel.someclient.com/api',
  };

  /// What `--flavor` this build was made with, or [fallback].
  ///
  /// Lower-cased because it goes straight into a URL and Flutter passes the
  /// name through as typed: `--flavor Wtms` would otherwise build a host name
  /// nobody wrote down.
  static String get name => (appFlavor ?? fallback).toLowerCase();

  static bool get isFallbackBuild => appFlavor == null;

  /// The panel this build talks to.
  static String get apiBaseUrl =>
      _offPattern[name] ?? 'https://$name.turnkeyinfotech.live/api';
}
