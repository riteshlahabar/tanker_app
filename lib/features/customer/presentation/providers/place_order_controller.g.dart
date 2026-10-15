// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_order_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deliverySlotOptionsHash() =>
    r'fc9fac7dcb331e374e031eacd552008eaf44ddd3';

/// The windows the panel offers, for the form's dropdown.
///
/// Copied from [deliverySlotOptions].
@ProviderFor(deliverySlotOptions)
final deliverySlotOptionsProvider =
    AutoDisposeFutureProvider<List<DeliverySlot>>.internal(
      deliverySlotOptions,
      name: r'deliverySlotOptionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deliverySlotOptionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeliverySlotOptionsRef =
    AutoDisposeFutureProviderRef<List<DeliverySlot>>;
String _$placeOrderControllerHash() =>
    r'ed4ecb257006927f2c51a54d3faf8e7bd39a93a9';

/// See also [PlaceOrderController].
@ProviderFor(PlaceOrderController)
final placeOrderControllerProvider =
    AutoDisposeNotifierProvider<PlaceOrderController, PlaceOrderState>.internal(
      PlaceOrderController.new,
      name: r'placeOrderControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$placeOrderControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PlaceOrderController = AutoDisposeNotifier<PlaceOrderState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
