// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_order_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$driverOrderDetailControllerHash() =>
    r'ea4798316971e08ceac8bc46e9cbf6ffffa4598d';

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

abstract class _$DriverOrderDetailController
    extends BuildlessAutoDisposeNotifier<DriverOrderDetailState> {
  late final int orderId;

  DriverOrderDetailState build(int orderId);
}

/// Backs the driver's Order Detail screen — the order itself, plus the one
/// status-advance action that applies at its current status.
///
/// Copied from [DriverOrderDetailController].
@ProviderFor(DriverOrderDetailController)
const driverOrderDetailControllerProvider = DriverOrderDetailControllerFamily();

/// Backs the driver's Order Detail screen — the order itself, plus the one
/// status-advance action that applies at its current status.
///
/// Copied from [DriverOrderDetailController].
class DriverOrderDetailControllerFamily extends Family<DriverOrderDetailState> {
  /// Backs the driver's Order Detail screen — the order itself, plus the one
  /// status-advance action that applies at its current status.
  ///
  /// Copied from [DriverOrderDetailController].
  const DriverOrderDetailControllerFamily();

  /// Backs the driver's Order Detail screen — the order itself, plus the one
  /// status-advance action that applies at its current status.
  ///
  /// Copied from [DriverOrderDetailController].
  DriverOrderDetailControllerProvider call(int orderId) {
    return DriverOrderDetailControllerProvider(orderId);
  }

  @override
  DriverOrderDetailControllerProvider getProviderOverride(
    covariant DriverOrderDetailControllerProvider provider,
  ) {
    return call(provider.orderId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'driverOrderDetailControllerProvider';
}

/// Backs the driver's Order Detail screen — the order itself, plus the one
/// status-advance action that applies at its current status.
///
/// Copied from [DriverOrderDetailController].
class DriverOrderDetailControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<
          DriverOrderDetailController,
          DriverOrderDetailState
        > {
  /// Backs the driver's Order Detail screen — the order itself, plus the one
  /// status-advance action that applies at its current status.
  ///
  /// Copied from [DriverOrderDetailController].
  DriverOrderDetailControllerProvider(int orderId)
    : this._internal(
        () => DriverOrderDetailController()..orderId = orderId,
        from: driverOrderDetailControllerProvider,
        name: r'driverOrderDetailControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$driverOrderDetailControllerHash,
        dependencies: DriverOrderDetailControllerFamily._dependencies,
        allTransitiveDependencies:
            DriverOrderDetailControllerFamily._allTransitiveDependencies,
        orderId: orderId,
      );

  DriverOrderDetailControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orderId,
  }) : super.internal();

  final int orderId;

  @override
  DriverOrderDetailState runNotifierBuild(
    covariant DriverOrderDetailController notifier,
  ) {
    return notifier.build(orderId);
  }

  @override
  Override overrideWith(DriverOrderDetailController Function() create) {
    return ProviderOverride(
      origin: this,
      override: DriverOrderDetailControllerProvider._internal(
        () => create()..orderId = orderId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        orderId: orderId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<
    DriverOrderDetailController,
    DriverOrderDetailState
  >
  createElement() {
    return _DriverOrderDetailControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DriverOrderDetailControllerProvider &&
        other.orderId == orderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, orderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DriverOrderDetailControllerRef
    on AutoDisposeNotifierProviderRef<DriverOrderDetailState> {
  /// The parameter `orderId` of this provider.
  int get orderId;
}

class _DriverOrderDetailControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          DriverOrderDetailController,
          DriverOrderDetailState
        >
    with DriverOrderDetailControllerRef {
  _DriverOrderDetailControllerProviderElement(super.provider);

  @override
  int get orderId => (origin as DriverOrderDetailControllerProvider).orderId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
