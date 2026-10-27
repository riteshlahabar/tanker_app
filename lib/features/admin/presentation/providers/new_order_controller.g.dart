// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_order_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$newOrderControllerHash() =>
    r'683339bad17b41239506506afff9c4791976ba70';

/// Backs the admin's "New Order" tab — a phone order written down by hand.
///
/// The amount is **not** a field: the admin picks the driver, the rate of the
/// tanker that driver holds fills itself in, and `rate × tankers` is the
/// total. Only a rate the admin types over becomes an override.
///
/// Copied from [NewOrderController].
@ProviderFor(NewOrderController)
final newOrderControllerProvider =
    AutoDisposeNotifierProvider<NewOrderController, NewOrderState>.internal(
      NewOrderController.new,
      name: r'newOrderControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$newOrderControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NewOrderController = AutoDisposeNotifier<NewOrderState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
