// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$prefsHash() => r'5fa0bcacf77fdc0f9b67039f0918b336db37ed09';

/// Shared preferences needs an async load, so `main()` does it once and
/// overrides this provider with the result. Reading it before that override is
/// a wiring mistake, which is why it throws rather than returning a default.
///
/// Copied from [prefs].
@ProviderFor(prefs)
final prefsProvider = Provider<Prefs>.internal(
  prefs,
  name: r'prefsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$prefsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PrefsRef = ProviderRef<Prefs>;
String _$secureStorageHash() => r'4a536bec8f508b79fb9b8d0f2510e34777052d1a';

/// See also [secureStorage].
@ProviderFor(secureStorage)
final secureStorageProvider = Provider<SecureStorage>.internal(
  secureStorage,
  name: r'secureStorageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$secureStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SecureStorageRef = ProviderRef<SecureStorage>;
String _$sessionExpiryBusHash() => r'220f50c7fac574a0850aa973c8be2815a3a491d4';

/// See also [sessionExpiryBus].
@ProviderFor(sessionExpiryBus)
final sessionExpiryBusProvider = Provider<SessionExpiryBus>.internal(
  sessionExpiryBus,
  name: r'sessionExpiryBusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionExpiryBusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SessionExpiryBusRef = ProviderRef<SessionExpiryBus>;
String _$dioHash() => r'a4205ebcb7f0c0648eeefc710defd858a5a71d8a';

/// The configured HTTP client. One instance for the whole app, so the token
/// refresh in [AuthInterceptor] is shared rather than repeated per screen.
///
/// Copied from [dio].
@ProviderFor(dio)
final dioProvider = Provider<Dio>.internal(
  dio,
  name: r'dioProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dioHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DioRef = ProviderRef<Dio>;
String _$apiClientHash() => r'8c4443c9c80070ab4a96afd745c581b3de2e615d';

/// See also [apiClient].
@ProviderFor(apiClient)
final apiClientProvider = Provider<ApiClient>.internal(
  apiClient,
  name: r'apiClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$apiClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ApiClientRef = ProviderRef<ApiClient>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
