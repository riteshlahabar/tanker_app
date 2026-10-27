// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_tankers_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminTankersControllerHash() =>
    r'3cb44f3898606f539e513a10f7568d9d6089e3b7';

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

abstract class _$AdminTankersController
    extends BuildlessAutoDisposeNotifier<AdminTankersState> {
  late final bool? initialStatus;

  AdminTankersState build({bool? initialStatus});
}

/// See also [AdminTankersController].
@ProviderFor(AdminTankersController)
const adminTankersControllerProvider = AdminTankersControllerFamily();

/// See also [AdminTankersController].
class AdminTankersControllerFamily extends Family<AdminTankersState> {
  /// See also [AdminTankersController].
  const AdminTankersControllerFamily();

  /// See also [AdminTankersController].
  AdminTankersControllerProvider call({bool? initialStatus}) {
    return AdminTankersControllerProvider(initialStatus: initialStatus);
  }

  @override
  AdminTankersControllerProvider getProviderOverride(
    covariant AdminTankersControllerProvider provider,
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
  String? get name => r'adminTankersControllerProvider';
}

/// See also [AdminTankersController].
class AdminTankersControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<
          AdminTankersController,
          AdminTankersState
        > {
  /// See also [AdminTankersController].
  AdminTankersControllerProvider({bool? initialStatus})
    : this._internal(
        () => AdminTankersController()..initialStatus = initialStatus,
        from: adminTankersControllerProvider,
        name: r'adminTankersControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$adminTankersControllerHash,
        dependencies: AdminTankersControllerFamily._dependencies,
        allTransitiveDependencies:
            AdminTankersControllerFamily._allTransitiveDependencies,
        initialStatus: initialStatus,
      );

  AdminTankersControllerProvider._internal(
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
  AdminTankersState runNotifierBuild(
    covariant AdminTankersController notifier,
  ) {
    return notifier.build(initialStatus: initialStatus);
  }

  @override
  Override overrideWith(AdminTankersController Function() create) {
    return ProviderOverride(
      origin: this,
      override: AdminTankersControllerProvider._internal(
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
  AutoDisposeNotifierProviderElement<AdminTankersController, AdminTankersState>
  createElement() {
    return _AdminTankersControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminTankersControllerProvider &&
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
mixin AdminTankersControllerRef
    on AutoDisposeNotifierProviderRef<AdminTankersState> {
  /// The parameter `initialStatus` of this provider.
  bool? get initialStatus;
}

class _AdminTankersControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          AdminTankersController,
          AdminTankersState
        >
    with AdminTankersControllerRef {
  _AdminTankersControllerProviderElement(super.provider);

  @override
  bool? get initialStatus =>
      (origin as AdminTankersControllerProvider).initialStatus;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
