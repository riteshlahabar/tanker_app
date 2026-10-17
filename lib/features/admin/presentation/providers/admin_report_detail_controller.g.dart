// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_report_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminReportDetailControllerHash() =>
    r'5dc4ccb785a313425420d45a2e358a75a7875021';

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

abstract class _$AdminReportDetailController
    extends BuildlessAutoDisposeNotifier<AdminReportDetailState> {
  late final String reportKey;

  AdminReportDetailState build(String reportKey);
}

/// Backs one report's detail screen — the server defaults the date range to
/// this month when the filter leaves `from`/`to` null, so the first load
/// needs no client-side default.
///
/// Copied from [AdminReportDetailController].
@ProviderFor(AdminReportDetailController)
const adminReportDetailControllerProvider = AdminReportDetailControllerFamily();

/// Backs one report's detail screen — the server defaults the date range to
/// this month when the filter leaves `from`/`to` null, so the first load
/// needs no client-side default.
///
/// Copied from [AdminReportDetailController].
class AdminReportDetailControllerFamily extends Family<AdminReportDetailState> {
  /// Backs one report's detail screen — the server defaults the date range to
  /// this month when the filter leaves `from`/`to` null, so the first load
  /// needs no client-side default.
  ///
  /// Copied from [AdminReportDetailController].
  const AdminReportDetailControllerFamily();

  /// Backs one report's detail screen — the server defaults the date range to
  /// this month when the filter leaves `from`/`to` null, so the first load
  /// needs no client-side default.
  ///
  /// Copied from [AdminReportDetailController].
  AdminReportDetailControllerProvider call(String reportKey) {
    return AdminReportDetailControllerProvider(reportKey);
  }

  @override
  AdminReportDetailControllerProvider getProviderOverride(
    covariant AdminReportDetailControllerProvider provider,
  ) {
    return call(provider.reportKey);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'adminReportDetailControllerProvider';
}

/// Backs one report's detail screen — the server defaults the date range to
/// this month when the filter leaves `from`/`to` null, so the first load
/// needs no client-side default.
///
/// Copied from [AdminReportDetailController].
class AdminReportDetailControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<
          AdminReportDetailController,
          AdminReportDetailState
        > {
  /// Backs one report's detail screen — the server defaults the date range to
  /// this month when the filter leaves `from`/`to` null, so the first load
  /// needs no client-side default.
  ///
  /// Copied from [AdminReportDetailController].
  AdminReportDetailControllerProvider(String reportKey)
    : this._internal(
        () => AdminReportDetailController()..reportKey = reportKey,
        from: adminReportDetailControllerProvider,
        name: r'adminReportDetailControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$adminReportDetailControllerHash,
        dependencies: AdminReportDetailControllerFamily._dependencies,
        allTransitiveDependencies:
            AdminReportDetailControllerFamily._allTransitiveDependencies,
        reportKey: reportKey,
      );

  AdminReportDetailControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.reportKey,
  }) : super.internal();

  final String reportKey;

  @override
  AdminReportDetailState runNotifierBuild(
    covariant AdminReportDetailController notifier,
  ) {
    return notifier.build(reportKey);
  }

  @override
  Override overrideWith(AdminReportDetailController Function() create) {
    return ProviderOverride(
      origin: this,
      override: AdminReportDetailControllerProvider._internal(
        () => create()..reportKey = reportKey,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        reportKey: reportKey,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<
    AdminReportDetailController,
    AdminReportDetailState
  >
  createElement() {
    return _AdminReportDetailControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminReportDetailControllerProvider &&
        other.reportKey == reportKey;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, reportKey.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AdminReportDetailControllerRef
    on AutoDisposeNotifierProviderRef<AdminReportDetailState> {
  /// The parameter `reportKey` of this provider.
  String get reportKey;
}

class _AdminReportDetailControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          AdminReportDetailController,
          AdminReportDetailState
        >
    with AdminReportDetailControllerRef {
  _AdminReportDetailControllerProviderElement(super.provider);

  @override
  String get reportKey =>
      (origin as AdminReportDetailControllerProvider).reportKey;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
