// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_new_order_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$driverNewOrderControllerHash() =>
    r'c327cc03bb398436bee0ebc7b2f45cfaf9c49c55';

/// Backs the driver's "New Order" tab — a job taken on the route.
///
/// Mirrors `NewOrderController`, the admin's, with **no `driverId` argument**:
/// the order always goes to the driver holding the token, decided server-side
/// in `DriverPlaceOrderRequest`. There is nothing for this controller to pass
/// and nothing a screen could get wrong.
///
/// The amount is not a field either. The rate of the driver's own tanker fills
/// itself in from `driverSummaryControllerProvider` and `rate × tankers` is the
/// total; only a rate typed over the vehicle's becomes an override.
///
/// Copied from [DriverNewOrderController].
@ProviderFor(DriverNewOrderController)
final driverNewOrderControllerProvider =
    AutoDisposeNotifierProvider<
      DriverNewOrderController,
      DriverNewOrderState
    >.internal(
      DriverNewOrderController.new,
      name: r'driverNewOrderControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$driverNewOrderControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DriverNewOrderController = AutoDisposeNotifier<DriverNewOrderState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
