// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_order_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$newOrderControllerHash() =>
    r'1f88c6ec2923815877fa97763314c8a52e50072c';

/// Backs the admin's "New Order" tab — a phone order typed in by hand, so
/// (unlike the customer's own form) the amount is a field here, not
/// server-computed.
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
