// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'duty_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dutyControllerHash() => r'd109fd23fd77ddf02112247e5c5864bd3bdd7799';

/// The on-duty toggle: phase 3's switch, and the bridge between the task
/// isolate and the alert controller that already knows how to ring.
///
/// The choice is remembered, so a driver who went on duty yesterday is on
/// duty again when the app opens rather than discovering at noon that it was
/// never watching. It is remembered **per device**, in [Prefs] — being on
/// duty is a fact about the phone in the cab, not about the account, and the
/// same driver's second handset should not start a service of its own.
///
/// Copied from [DutyController].
@ProviderFor(DutyController)
final dutyControllerProvider =
    NotifierProvider<DutyController, DutyState>.internal(
      DutyController.new,
      name: r'dutyControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dutyControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DutyController = Notifier<DutyState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
