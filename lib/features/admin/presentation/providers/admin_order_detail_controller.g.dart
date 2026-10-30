// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_order_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminOrderDetailControllerHash() =>
    r'60ce961168687755bfc3425983a74bc81c055116';

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

abstract class _$AdminOrderDetailController
    extends BuildlessAutoDisposeNotifier<AdminOrderDetailState> {
  late final int orderId;

  AdminOrderDetailState build(int orderId);
}

/// See also [AdminOrderDetailController].
@ProviderFor(AdminOrderDetailController)
const adminOrderDetailControllerProvider = AdminOrderDetailControllerFamily();

/// See also [AdminOrderDetailController].
class AdminOrderDetailControllerFamily extends Family<AdminOrderDetailState> {
  /// See also [AdminOrderDetailController].
  const AdminOrderDetailControllerFamily();

  /// See also [AdminOrderDetailController].
  AdminOrderDetailControllerProvider call(int orderId) {
    return AdminOrderDetailControllerProvider(orderId);
  }

  @override
  AdminOrderDetailControllerProvider getProviderOverride(
    covariant AdminOrderDetailControllerProvider provider,
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
  String? get name => r'adminOrderDetailControllerProvider';
}

/// See also [AdminOrderDetailController].
class AdminOrderDetailControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<
          AdminOrderDetailController,
          AdminOrderDetailState
        > {
  /// See also [AdminOrderDetailController].
  AdminOrderDetailControllerProvider(int orderId)
    : this._internal(
        () => AdminOrderDetailController()..orderId = orderId,
        from: adminOrderDetailControllerProvider,
        name: r'adminOrderDetailControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$adminOrderDetailControllerHash,
        dependencies: AdminOrderDetailControllerFamily._dependencies,
        allTransitiveDependencies:
            AdminOrderDetailControllerFamily._allTransitiveDependencies,
        orderId: orderId,
      );

  AdminOrderDetailControllerProvider._internal(
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
  AdminOrderDetailState runNotifierBuild(
    covariant AdminOrderDetailController notifier,
  ) {
    return notifier.build(orderId);
  }

  @override
  Override overrideWith(AdminOrderDetailController Function() create) {
    return ProviderOverride(
      origin: this,
      override: AdminOrderDetailControllerProvider._internal(
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
    AdminOrderDetailController,
    AdminOrderDetailState
  >
  createElement() {
    return _AdminOrderDetailControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminOrderDetailControllerProvider &&
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
mixin AdminOrderDetailControllerRef
    on AutoDisposeNotifierProviderRef<AdminOrderDetailState> {
  /// The parameter `orderId` of this provider.
  int get orderId;
}

class _AdminOrderDetailControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          AdminOrderDetailController,
          AdminOrderDetailState
        >
    with AdminOrderDetailControllerRef {
  _AdminOrderDetailControllerProviderElement(super.provider);

  @override
  int get orderId => (origin as AdminOrderDetailControllerProvider).orderId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
