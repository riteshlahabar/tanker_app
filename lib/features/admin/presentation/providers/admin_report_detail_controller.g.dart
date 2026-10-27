// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_report_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminReportDetailControllerHash() =>
    r'86013351e6f42cc4bc2e1da96e5e1e2c2839284e';

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
  late final DateTime? initialFrom;
  late final DateTime? initialTo;

  AdminReportDetailState build(
    String reportKey, {
    DateTime? initialFrom,
    DateTime? initialTo,
  });
}

/// Backs one report's detail screen — the server defaults the date range to
/// this month when the filter leaves `from`/`to` null, so the first load
/// needs no client-side default.
///
/// **A screen opening the report at a particular range passes it here**, as
/// part of the provider's identity, rather than setting it afterwards: the
/// dashboard's Revenue tile wants today. Riverpod forbids modifying a
/// provider from `initState`, and seeding it once the opening load has
/// started races two requests — so the range has to be known at `build()`,
/// and then the one request `FirstLoad` fires already carries it.
///
/// Copied from [AdminReportDetailController].
@ProviderFor(AdminReportDetailController)
const adminReportDetailControllerProvider = AdminReportDetailControllerFamily();

/// Backs one report's detail screen — the server defaults the date range to
/// this month when the filter leaves `from`/`to` null, so the first load
/// needs no client-side default.
///
/// **A screen opening the report at a particular range passes it here**, as
/// part of the provider's identity, rather than setting it afterwards: the
/// dashboard's Revenue tile wants today. Riverpod forbids modifying a
/// provider from `initState`, and seeding it once the opening load has
/// started races two requests — so the range has to be known at `build()`,
/// and then the one request `FirstLoad` fires already carries it.
///
/// Copied from [AdminReportDetailController].
class AdminReportDetailControllerFamily extends Family<AdminReportDetailState> {
  /// Backs one report's detail screen — the server defaults the date range to
  /// this month when the filter leaves `from`/`to` null, so the first load
  /// needs no client-side default.
  ///
  /// **A screen opening the report at a particular range passes it here**, as
  /// part of the provider's identity, rather than setting it afterwards: the
  /// dashboard's Revenue tile wants today. Riverpod forbids modifying a
  /// provider from `initState`, and seeding it once the opening load has
  /// started races two requests — so the range has to be known at `build()`,
  /// and then the one request `FirstLoad` fires already carries it.
  ///
  /// Copied from [AdminReportDetailController].
  const AdminReportDetailControllerFamily();

  /// Backs one report's detail screen — the server defaults the date range to
  /// this month when the filter leaves `from`/`to` null, so the first load
  /// needs no client-side default.
  ///
  /// **A screen opening the report at a particular range passes it here**, as
  /// part of the provider's identity, rather than setting it afterwards: the
  /// dashboard's Revenue tile wants today. Riverpod forbids modifying a
  /// provider from `initState`, and seeding it once the opening load has
  /// started races two requests — so the range has to be known at `build()`,
  /// and then the one request `FirstLoad` fires already carries it.
  ///
  /// Copied from [AdminReportDetailController].
  AdminReportDetailControllerProvider call(
    String reportKey, {
    DateTime? initialFrom,
    DateTime? initialTo,
  }) {
    return AdminReportDetailControllerProvider(
      reportKey,
      initialFrom: initialFrom,
      initialTo: initialTo,
    );
  }

  @override
  AdminReportDetailControllerProvider getProviderOverride(
    covariant AdminReportDetailControllerProvider provider,
  ) {
    return call(
      provider.reportKey,
      initialFrom: provider.initialFrom,
      initialTo: provider.initialTo,
    );
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
/// **A screen opening the report at a particular range passes it here**, as
/// part of the provider's identity, rather than setting it afterwards: the
/// dashboard's Revenue tile wants today. Riverpod forbids modifying a
/// provider from `initState`, and seeding it once the opening load has
/// started races two requests — so the range has to be known at `build()`,
/// and then the one request `FirstLoad` fires already carries it.
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
  /// **A screen opening the report at a particular range passes it here**, as
  /// part of the provider's identity, rather than setting it afterwards: the
  /// dashboard's Revenue tile wants today. Riverpod forbids modifying a
  /// provider from `initState`, and seeding it once the opening load has
  /// started races two requests — so the range has to be known at `build()`,
  /// and then the one request `FirstLoad` fires already carries it.
  ///
  /// Copied from [AdminReportDetailController].
  AdminReportDetailControllerProvider(
    String reportKey, {
    DateTime? initialFrom,
    DateTime? initialTo,
  }) : this._internal(
         () => AdminReportDetailController()
           ..reportKey = reportKey
           ..initialFrom = initialFrom
           ..initialTo = initialTo,
         from: adminReportDetailControllerProvider,
         name: r'adminReportDetailControllerProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$adminReportDetailControllerHash,
         dependencies: AdminReportDetailControllerFamily._dependencies,
         allTransitiveDependencies:
             AdminReportDetailControllerFamily._allTransitiveDependencies,
         reportKey: reportKey,
         initialFrom: initialFrom,
         initialTo: initialTo,
       );

  AdminReportDetailControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.reportKey,
    required this.initialFrom,
    required this.initialTo,
  }) : super.internal();

  final String reportKey;
  final DateTime? initialFrom;
  final DateTime? initialTo;

  @override
  AdminReportDetailState runNotifierBuild(
    covariant AdminReportDetailController notifier,
  ) {
    return notifier.build(
      reportKey,
      initialFrom: initialFrom,
      initialTo: initialTo,
    );
  }

  @override
  Override overrideWith(AdminReportDetailController Function() create) {
    return ProviderOverride(
      origin: this,
      override: AdminReportDetailControllerProvider._internal(
        () => create()
          ..reportKey = reportKey
          ..initialFrom = initialFrom
          ..initialTo = initialTo,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        reportKey: reportKey,
        initialFrom: initialFrom,
        initialTo: initialTo,
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
        other.reportKey == reportKey &&
        other.initialFrom == initialFrom &&
        other.initialTo == initialTo;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, reportKey.hashCode);
    hash = _SystemHash.combine(hash, initialFrom.hashCode);
    hash = _SystemHash.combine(hash, initialTo.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AdminReportDetailControllerRef
    on AutoDisposeNotifierProviderRef<AdminReportDetailState> {
  /// The parameter `reportKey` of this provider.
  String get reportKey;

  /// The parameter `initialFrom` of this provider.
  DateTime? get initialFrom;

  /// The parameter `initialTo` of this provider.
  DateTime? get initialTo;
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
  @override
  DateTime? get initialFrom =>
      (origin as AdminReportDetailControllerProvider).initialFrom;
  @override
  DateTime? get initialTo =>
      (origin as AdminReportDetailControllerProvider).initialTo;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
