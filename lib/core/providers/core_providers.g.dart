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
String _$deliverySlotRepositoryHash() =>
    r'bcbe50827a9173a7734c9947e6de4d58f5b909c9';

/// Shared by every role that needs the panel's delivery windows (the
/// customer's order form, the admin's New Order).
///
/// Copied from [deliverySlotRepository].
@ProviderFor(deliverySlotRepository)
final deliverySlotRepositoryProvider =
    Provider<DeliverySlotRepository>.internal(
      deliverySlotRepository,
      name: r'deliverySlotRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deliverySlotRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeliverySlotRepositoryRef = ProviderRef<DeliverySlotRepository>;
String _$customerLookupRepositoryHash() =>
    r'8a6afe4a595d8771ce8047709b11a4c353abb061';

/// Customer search for whichever role is writing an order.
///
/// The endpoint is chosen **here, once**, from the signed-in role: an admin
/// talks to `/admin/customers`, a driver to `/driver/customers`. A screen that
/// picked its own path would 403 the moment the shared picker was reused by
/// the other role, and the failure would read as a broken picker rather than a
/// wrong URL. Anyone else — a customer, or a session still being restored —
/// gets the driver path, which their token simply cannot use; no role but
/// those two has a customer picker to show.
///
/// Copied from [customerLookupRepository].
@ProviderFor(customerLookupRepository)
final customerLookupRepositoryProvider =
    Provider<CustomerLookupRepository>.internal(
      customerLookupRepository,
      name: r'customerLookupRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$customerLookupRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CustomerLookupRepositoryRef = ProviderRef<CustomerLookupRepository>;
String _$deliverySlotOptionsHash() =>
    r'fc9fac7dcb331e374e031eacd552008eaf44ddd3';

/// The windows the panel offers, for a form's dropdown.
///
/// Copied from [deliverySlotOptions].
@ProviderFor(deliverySlotOptions)
final deliverySlotOptionsProvider =
    AutoDisposeFutureProvider<List<DeliverySlot>>.internal(
      deliverySlotOptions,
      name: r'deliverySlotOptionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deliverySlotOptionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeliverySlotOptionsRef =
    AutoDisposeFutureProviderRef<List<DeliverySlot>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
