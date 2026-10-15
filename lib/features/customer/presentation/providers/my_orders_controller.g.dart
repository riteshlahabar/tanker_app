// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_orders_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$myOrdersControllerHash() =>
    r'94f86fa6c9034c0e96e20aa3ae2f8832d3cf2343';

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

abstract class _$MyOrdersController
    extends BuildlessAutoDisposeNotifier<OrdersListState> {
  late final bool openOnly;

  OrdersListState build(bool openOnly);
}

/// One of these per tab (`openOnly: true` for Ongoing, `false` for History) —
/// each keeps its own page cursor so switching tabs never re-fetches the
/// other's list.
///
/// Copied from [MyOrdersController].
@ProviderFor(MyOrdersController)
const myOrdersControllerProvider = MyOrdersControllerFamily();

/// One of these per tab (`openOnly: true` for Ongoing, `false` for History) —
/// each keeps its own page cursor so switching tabs never re-fetches the
/// other's list.
///
/// Copied from [MyOrdersController].
class MyOrdersControllerFamily extends Family<OrdersListState> {
  /// One of these per tab (`openOnly: true` for Ongoing, `false` for History) —
  /// each keeps its own page cursor so switching tabs never re-fetches the
  /// other's list.
  ///
  /// Copied from [MyOrdersController].
  const MyOrdersControllerFamily();

  /// One of these per tab (`openOnly: true` for Ongoing, `false` for History) —
  /// each keeps its own page cursor so switching tabs never re-fetches the
  /// other's list.
  ///
  /// Copied from [MyOrdersController].
  MyOrdersControllerProvider call(bool openOnly) {
    return MyOrdersControllerProvider(openOnly);
  }

  @override
  MyOrdersControllerProvider getProviderOverride(
    covariant MyOrdersControllerProvider provider,
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
  String? get name => r'myOrdersControllerProvider';
}

/// One of these per tab (`openOnly: true` for Ongoing, `false` for History) —
/// each keeps its own page cursor so switching tabs never re-fetches the
/// other's list.
///
/// Copied from [MyOrdersController].
class MyOrdersControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<MyOrdersController, OrdersListState> {
  /// One of these per tab (`openOnly: true` for Ongoing, `false` for History) —
  /// each keeps its own page cursor so switching tabs never re-fetches the
  /// other's list.
  ///
  /// Copied from [MyOrdersController].
  MyOrdersControllerProvider(bool openOnly)
    : this._internal(
        () => MyOrdersController()..openOnly = openOnly,
        from: myOrdersControllerProvider,
        name: r'myOrdersControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$myOrdersControllerHash,
        dependencies: MyOrdersControllerFamily._dependencies,
        allTransitiveDependencies:
            MyOrdersControllerFamily._allTransitiveDependencies,
        openOnly: openOnly,
      );

  MyOrdersControllerProvider._internal(
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
  OrdersListState runNotifierBuild(covariant MyOrdersController notifier) {
    return notifier.build(openOnly);
  }

  @override
  Override overrideWith(MyOrdersController Function() create) {
    return ProviderOverride(
      origin: this,
      override: MyOrdersControllerProvider._internal(
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
  AutoDisposeNotifierProviderElement<MyOrdersController, OrdersListState>
  createElement() {
    return _MyOrdersControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MyOrdersControllerProvider && other.openOnly == openOnly;
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
mixin MyOrdersControllerRef on AutoDisposeNotifierProviderRef<OrdersListState> {
  /// The parameter `openOnly` of this provider.
  bool get openOnly;
}

class _MyOrdersControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<MyOrdersController, OrdersListState>
    with MyOrdersControllerRef {
  _MyOrdersControllerProviderElement(super.provider);

  @override
  bool get openOnly => (origin as MyOrdersControllerProvider).openOnly;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
