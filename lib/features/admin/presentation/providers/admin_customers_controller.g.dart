// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_customers_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminCustomersControllerHash() =>
    r'a1e350fa1f976d7724728d9130e75677133ad2f7';

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

abstract class _$AdminCustomersController
    extends BuildlessAutoDisposeNotifier<AdminCustomersState> {
  late final bool? initialStatus;

  AdminCustomersState build({bool? initialStatus});
}

/// See also [AdminCustomersController].
@ProviderFor(AdminCustomersController)
const adminCustomersControllerProvider = AdminCustomersControllerFamily();

/// See also [AdminCustomersController].
class AdminCustomersControllerFamily extends Family<AdminCustomersState> {
  /// See also [AdminCustomersController].
  const AdminCustomersControllerFamily();

  /// See also [AdminCustomersController].
  AdminCustomersControllerProvider call({bool? initialStatus}) {
    return AdminCustomersControllerProvider(initialStatus: initialStatus);
  }

  @override
  AdminCustomersControllerProvider getProviderOverride(
    covariant AdminCustomersControllerProvider provider,
  ) {
    return call(initialStatus: provider.initialStatus);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'adminCustomersControllerProvider';
}

/// See also [AdminCustomersController].
class AdminCustomersControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<
          AdminCustomersController,
          AdminCustomersState
        > {
  /// See also [AdminCustomersController].
  AdminCustomersControllerProvider({bool? initialStatus})
    : this._internal(
        () => AdminCustomersController()..initialStatus = initialStatus,
        from: adminCustomersControllerProvider,
        name: r'adminCustomersControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$adminCustomersControllerHash,
        dependencies: AdminCustomersControllerFamily._dependencies,
        allTransitiveDependencies:
            AdminCustomersControllerFamily._allTransitiveDependencies,
        initialStatus: initialStatus,
      );

  AdminCustomersControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.initialStatus,
  }) : super.internal();

  final bool? initialStatus;

  @override
  AdminCustomersState runNotifierBuild(
    covariant AdminCustomersController notifier,
  ) {
    return notifier.build(initialStatus: initialStatus);
  }

  @override
  Override overrideWith(AdminCustomersController Function() create) {
    return ProviderOverride(
      origin: this,
      override: AdminCustomersControllerProvider._internal(
        () => create()..initialStatus = initialStatus,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        initialStatus: initialStatus,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<
    AdminCustomersController,
    AdminCustomersState
  >
  createElement() {
    return _AdminCustomersControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminCustomersControllerProvider &&
        other.initialStatus == initialStatus;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, initialStatus.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AdminCustomersControllerRef
    on AutoDisposeNotifierProviderRef<AdminCustomersState> {
  /// The parameter `initialStatus` of this provider.
  bool? get initialStatus;
}

class _AdminCustomersControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          AdminCustomersController,
          AdminCustomersState
        >
    with AdminCustomersControllerRef {
  _AdminCustomersControllerProviderElement(super.provider);

  @override
  bool? get initialStatus =>
      (origin as AdminCustomersControllerProvider).initialStatus;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
