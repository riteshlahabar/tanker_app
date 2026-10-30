// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opened_order.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$openedOrderHash() => r'8d02a5830259b50a9316b11e14334cf8c37f120c';

/// "An order detail screen just opened" — announced here, and acted on by
/// whoever cares.
///
/// The buzzer stops when the recipient *opens* the order, and they may well
/// reach it from their orders list or the dashboard having heard the phone and
/// gone looking. So the two detail controllers have to say that they opened,
/// and the alert controller has to hear it.
///
/// The dependency runs **this way round** on purpose. Having the detail
/// controllers read the alert controller instead made every order detail
/// depend on the signed-in session, and so on secure storage — which took
/// three unrelated unit tests down with "Binding has not yet been
/// initialized". This provider depends on nothing, and nothing but the alert
/// controller listens to it, so for a customer — who is never rung — the
/// announcement simply falls on no ears.
///
/// [seq] exists so that opening the same order twice is two events rather
/// than one unchanged value a listener would never be told about.
///
/// Copied from [OpenedOrder].
@ProviderFor(OpenedOrder)
final openedOrderProvider =
    NotifierProvider<OpenedOrder, OpenedOrderMark?>.internal(
      OpenedOrder.new,
      name: r'openedOrderProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$openedOrderHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OpenedOrder = Notifier<OpenedOrderMark?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
