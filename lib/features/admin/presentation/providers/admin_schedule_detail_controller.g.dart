// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_schedule_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminScheduleDetailControllerHash() =>
    r'85e0deaf3e17486a2ea8b92b1c7f9ba30f9ba0d2';

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

abstract class _$AdminScheduleDetailController
    extends BuildlessAutoDisposeNotifier<AdminScheduleDetailState> {
  late final int scheduleId;

  AdminScheduleDetailState build(int scheduleId);
}

/// See also [AdminScheduleDetailController].
@ProviderFor(AdminScheduleDetailController)
const adminScheduleDetailControllerProvider =
    AdminScheduleDetailControllerFamily();

/// See also [AdminScheduleDetailController].
class AdminScheduleDetailControllerFamily
    extends Family<AdminScheduleDetailState> {
  /// See also [AdminScheduleDetailController].
  const AdminScheduleDetailControllerFamily();

  /// See also [AdminScheduleDetailController].
  AdminScheduleDetailControllerProvider call(int scheduleId) {
    return AdminScheduleDetailControllerProvider(scheduleId);
  }

  @override
  AdminScheduleDetailControllerProvider getProviderOverride(
    covariant AdminScheduleDetailControllerProvider provider,
  ) {
    return call(provider.scheduleId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'adminScheduleDetailControllerProvider';
}

/// See also [AdminScheduleDetailController].
class AdminScheduleDetailControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<
          AdminScheduleDetailController,
          AdminScheduleDetailState
        > {
  /// See also [AdminScheduleDetailController].
  AdminScheduleDetailControllerProvider(int scheduleId)
    : this._internal(
        () => AdminScheduleDetailController()..scheduleId = scheduleId,
        from: adminScheduleDetailControllerProvider,
        name: r'adminScheduleDetailControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$adminScheduleDetailControllerHash,
        dependencies: AdminScheduleDetailControllerFamily._dependencies,
        allTransitiveDependencies:
            AdminScheduleDetailControllerFamily._allTransitiveDependencies,
        scheduleId: scheduleId,
      );

  AdminScheduleDetailControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.scheduleId,
  }) : super.internal();

  final int scheduleId;

  @override
  AdminScheduleDetailState runNotifierBuild(
    covariant AdminScheduleDetailController notifier,
  ) {
    return notifier.build(scheduleId);
  }

  @override
  Override overrideWith(AdminScheduleDetailController Function() create) {
    return ProviderOverride(
      origin: this,
      override: AdminScheduleDetailControllerProvider._internal(
        () => create()..scheduleId = scheduleId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        scheduleId: scheduleId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<
    AdminScheduleDetailController,
    AdminScheduleDetailState
  >
  createElement() {
    return _AdminScheduleDetailControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminScheduleDetailControllerProvider &&
        other.scheduleId == scheduleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, scheduleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AdminScheduleDetailControllerRef
    on AutoDisposeNotifierProviderRef<AdminScheduleDetailState> {
  /// The parameter `scheduleId` of this provider.
  int get scheduleId;
}

class _AdminScheduleDetailControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          AdminScheduleDetailController,
          AdminScheduleDetailState
        >
    with AdminScheduleDetailControllerRef {
  _AdminScheduleDetailControllerProviderElement(super.provider);

  @override
  int get scheduleId =>
      (origin as AdminScheduleDetailControllerProvider).scheduleId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
