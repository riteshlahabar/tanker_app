// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$orderDetailControllerHash() =>
    r'c9dd69b7d32adacf39cb5fa9bbe01ad556040f16';

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

abstract class _$OrderDetailController
    extends BuildlessAutoDisposeNotifier<OrderDetailState> {
  late final int orderId;

  OrderDetailState build(int orderId);
}

/// See also [OrderDetailController].
@ProviderFor(OrderDetailController)
const orderDetailControllerProvider = OrderDetailControllerFamily();

/// See also [OrderDetailController].
class OrderDetailControllerFamily extends Family<OrderDetailState> {
  /// See also [OrderDetailController].
  const OrderDetailControllerFamily();

  /// See also [OrderDetailController].
  OrderDetailControllerProvider call(int orderId) {
    return OrderDetailControllerProvider(orderId);
  }

  @override
  OrderDetailControllerProvider getProviderOverride(
    covariant OrderDetailControllerProvider provider,
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
  String? get name => r'orderDetailControllerProvider';
}

/// See also [OrderDetailController].
class OrderDetailControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<
          OrderDetailController,
          OrderDetailState
        > {
  /// See also [OrderDetailController].
  OrderDetailControllerProvider(int orderId)
    : this._internal(
        () => OrderDetailController()..orderId = orderId,
        from: orderDetailControllerProvider,
        name: r'orderDetailControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$orderDetailControllerHash,
        dependencies: OrderDetailControllerFamily._dependencies,
        allTransitiveDependencies:
            OrderDetailControllerFamily._allTransitiveDependencies,
        orderId: orderId,
      );

  OrderDetailControllerProvider._internal(
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
  OrderDetailState runNotifierBuild(covariant OrderDetailController notifier) {
    return notifier.build(orderId);
  }

  @override
  Override overrideWith(OrderDetailController Function() create) {
    return ProviderOverride(
      origin: this,
      override: OrderDetailControllerProvider._internal(
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
  AutoDisposeNotifierProviderElement<OrderDetailController, OrderDetailState>
  createElement() {
    return _OrderDetailControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderDetailControllerProvider && other.orderId == orderId;
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
mixin OrderDetailControllerRef
    on AutoDisposeNotifierProviderRef<OrderDetailState> {
  /// The parameter `orderId` of this provider.
  int get orderId;
}

class _OrderDetailControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          OrderDetailController,
          OrderDetailState
        >
    with OrderDetailControllerRef {
  _OrderDetailControllerProviderElement(super.provider);

  @override
  int get orderId => (origin as OrderDetailControllerProvider).orderId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
