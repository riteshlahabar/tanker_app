// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_orders_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminOrdersControllerHash() =>
    r'deb27a0d3223a9a808cbb799b41f856b916e9640';

/// The admin's Orders list — same infinite-scroll shape as the customer's and
/// driver's own order lists, with a filter the admin can change at any time.
///
/// Copied from [AdminOrdersController].
@ProviderFor(AdminOrdersController)
final adminOrdersControllerProvider =
    AutoDisposeNotifierProvider<
      AdminOrdersController,
      AdminOrdersState
    >.internal(
      AdminOrdersController.new,
      name: r'adminOrdersControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminOrdersControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AdminOrdersController = AutoDisposeNotifier<AdminOrdersState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
