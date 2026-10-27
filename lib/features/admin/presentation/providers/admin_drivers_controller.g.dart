// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_drivers_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminDriversControllerHash() =>
    r'83214cd93cf91b83dec317f51585281b21b153ce';

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

abstract class _$AdminDriversController
    extends BuildlessAutoDisposeNotifier<AdminDriversState> {
  late final bool? initialStatus;

  AdminDriversState build({bool? initialStatus});
}

/// See also [AdminDriversController].
@ProviderFor(AdminDriversController)
const adminDriversControllerProvider = AdminDriversControllerFamily();

/// See also [AdminDriversController].
class AdminDriversControllerFamily extends Family<AdminDriversState> {
  /// See also [AdminDriversController].
  const AdminDriversControllerFamily();

  /// See also [AdminDriversController].
  AdminDriversControllerProvider call({bool? initialStatus}) {
    return AdminDriversControllerProvider(initialStatus: initialStatus);
  }

  @override
  AdminDriversControllerProvider getProviderOverride(
    covariant AdminDriversControllerProvider provider,
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
  String? get name => r'adminDriversControllerProvider';
}

/// See also [AdminDriversController].
class AdminDriversControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<
          AdminDriversController,
          AdminDriversState
        > {
  /// See also [AdminDriversController].
  AdminDriversControllerProvider({bool? initialStatus})
    : this._internal(
        () => AdminDriversController()..initialStatus = initialStatus,
        from: adminDriversControllerProvider,
        name: r'adminDriversControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$adminDriversControllerHash,
        dependencies: AdminDriversControllerFamily._dependencies,
        allTransitiveDependencies:
            AdminDriversControllerFamily._allTransitiveDependencies,
        initialStatus: initialStatus,
      );

  AdminDriversControllerProvider._internal(
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
  AdminDriversState runNotifierBuild(
    covariant AdminDriversController notifier,
  ) {
    return notifier.build(initialStatus: initialStatus);
  }

  @override
  Override overrideWith(AdminDriversController Function() create) {
    return ProviderOverride(
      origin: this,
      override: AdminDriversControllerProvider._internal(
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
  AutoDisposeNotifierProviderElement<AdminDriversController, AdminDriversState>
  createElement() {
    return _AdminDriversControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminDriversControllerProvider &&
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
mixin AdminDriversControllerRef
    on AutoDisposeNotifierProviderRef<AdminDriversState> {
  /// The parameter `initialStatus` of this provider.
  bool? get initialStatus;
}

class _AdminDriversControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          AdminDriversController,
          AdminDriversState
        >
    with AdminDriversControllerRef {
  _AdminDriversControllerProviderElement(super.provider);

  @override
  bool? get initialStatus =>
      (origin as AdminDriversControllerProvider).initialStatus;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
