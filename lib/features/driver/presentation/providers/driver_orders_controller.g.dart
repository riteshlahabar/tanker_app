// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_orders_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$driverOrdersControllerHash() =>
    r'ac8470b2f805129b27b3ec0e28624a3314a2bba5';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$DriverOrdersController
    extends BuildlessAutoDisposeNotifier<DriverOrdersState> {
  late final bool openOnly;

  DriverOrdersState build(bool openOnly);
}

/// One of these per tab (`openOnly: true` for Active, `false` for Delivered),
/// mirroring the customer's `MyOrdersController` but pointed at the driver's
/// own endpoint.
///
/// Copied from [DriverOrdersController].
@ProviderFor(DriverOrdersController)
const driverOrdersControllerProvider = DriverOrdersControllerFamily();

/// One of these per tab (`openOnly: true` for Active, `false` for Delivered),
/// mirroring the customer's `MyOrdersController` but pointed at the driver's
/// own endpoint.
///
/// Copied from [DriverOrdersController].
class DriverOrdersControllerFamily extends Family<DriverOrdersState> {
  /// One of these per tab (`openOnly: true` for Active, `false` for Delivered),
  /// mirroring the customer's `MyOrdersController` but pointed at the driver's
  /// own endpoint.
  ///
  /// Copied from [DriverOrdersController].
  const DriverOrdersControllerFamily();

  /// One of these per tab (`openOnly: true` for Active, `false` for Delivered),
  /// mirroring the customer's `MyOrdersController` but pointed at the driver's
  /// own endpoint.
  ///
  /// Copied from [DriverOrdersController].
  DriverOrdersControllerProvider call(bool openOnly) {
    return DriverOrdersControllerProvider(openOnly);
  }

  @override
  DriverOrdersControllerProvider getProviderOverride(
    covariant DriverOrdersControllerProvider provider,
  ) {
    return call(provider.openOnly);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'driverOrdersControllerProvider';
}

/// One of these per tab (`openOnly: true` for Active, `false` for Delivered),
/// mirroring the customer's `MyOrdersController` but pointed at the driver's
/// own endpoint.
///
/// Copied from [DriverOrdersController].
class DriverOrdersControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<
          DriverOrdersController,
          DriverOrdersState
        > {
  /// One of these per tab (`openOnly: true` for Active, `false` for Delivered),
  /// mirroring the customer's `MyOrdersController` but pointed at the driver's
  /// own endpoint.
  ///
  /// Copied from [DriverOrdersController].
  DriverOrdersControllerProvider(bool openOnly)
    : this._internal(
        () => DriverOrdersController()..openOnly = openOnly,
        from: driverOrdersControllerProvider,
        name: r'driverOrdersControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$driverOrdersControllerHash,
        dependencies: DriverOrdersControllerFamily._dependencies,
        allTransitiveDependencies:
            DriverOrdersControllerFamily._allTransitiveDependencies,
        openOnly: openOnly,
      );

  DriverOrdersControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.openOnly,
  }) : super.internal();

  final bool openOnly;

  @override
  DriverOrdersState runNotifierBuild(
    covariant DriverOrdersController notifier,
  ) {
    return notifier.build(openOnly);
  }

  @override
  Override overrideWith(DriverOrdersController Function() create) {
    return ProviderOverride(
      origin: this,
      override: DriverOrdersControllerProvider._internal(
        () => create()..openOnly = openOnly,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        openOnly: openOnly,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<DriverOrdersController, DriverOrdersState>
  createElement() {
    return _DriverOrdersControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DriverOrdersControllerProvider &&
        other.openOnly == openOnly;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, openOnly.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DriverOrdersControllerRef
    on AutoDisposeNotifierProviderRef<DriverOrdersState> {
  /// The parameter `openOnly` of this provider.
  bool get openOnly;
}

class _DriverOrdersControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          DriverOrdersController,
          DriverOrdersState
        >
    with DriverOrdersControllerRef {
  _DriverOrdersControllerProviderElement(super.provider);

  @override
  bool get openOnly => (origin as DriverOrdersControllerProvider).openOnly;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
