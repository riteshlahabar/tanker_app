// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_alerts_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$orderAlertsControllerHash() =>
    r'9b3b6fb8d8d0aa3dd6adbee6d0571d79014260cc';

/// The buzzer: a new order rings on the other side until it is seen.
///
/// Two timers, deliberately not one:
///
///  * a **poll** asking the panel what is still unseen. The server owns that
///    fact (`orders.alert_for` / `alert_seen_at`), which is what stops an
///    order re-ringing after a reinstall, on a second device, or when the
///    token refreshes;
///  * a **tick** that re-asserts "should it be sounding now" against
///    [BuzzerSchedule]. It re-asserts rather than tracking edges, so a missed
///    tick cannot leave the phone ringing for ever.
///
/// First sighting is kept **here, per order id**, not read off the order: the
/// minute of ringing belongs to the moment this phone learned about the job,
/// not to the moment the row was written. An app that was shut, or a phone in
/// a tunnel, still gets its full minute when it comes back.
///
/// Phase 3 adds no second code path: the duty service simply keeps the
/// process awake so these timers keep firing with the app minimised.
///
/// Copied from [OrderAlertsController].
@ProviderFor(OrderAlertsController)
final orderAlertsControllerProvider =
    NotifierProvider<OrderAlertsController, OrderAlertsState>.internal(
      OrderAlertsController.new,
      name: r'orderAlertsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$orderAlertsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OrderAlertsController = Notifier<OrderAlertsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
