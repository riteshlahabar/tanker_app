// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_schedule_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$myScheduleControllerHash() =>
    r'782fa7324d7b508a0e7f7cdb66fb28b975e8ee1d';

/// Backs both the Home schedule card and the My Deliveries screen, so a skip
/// made on one is reflected on the other without a second fetch.
///
/// Copied from [MyScheduleController].
@ProviderFor(MyScheduleController)
final myScheduleControllerProvider =
    AutoDisposeNotifierProvider<MyScheduleController, MyScheduleState>.internal(
      MyScheduleController.new,
      name: r'myScheduleControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$myScheduleControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MyScheduleController = AutoDisposeNotifier<MyScheduleState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
