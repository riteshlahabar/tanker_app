// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_picker_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$driverPickerControllerHash() =>
    r'1a99108af42c5c0957a348ed219a1fbea0f85a86';

/// Search-as-you-type for the Assign sheet's driver field. A short debounce
/// keeps a fast typist from firing a request per keystroke.
///
/// Copied from [DriverPickerController].
@ProviderFor(DriverPickerController)
final driverPickerControllerProvider =
    AutoDisposeNotifierProvider<
      DriverPickerController,
      PickerState<DriverOption>
    >.internal(
      DriverPickerController.new,
      name: r'driverPickerControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$driverPickerControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DriverPickerController =
    AutoDisposeNotifier<PickerState<DriverOption>>;
String _$customerPickerControllerHash() =>
    r'be9c934f0792e6371a5ef96d6804ef0bab412c22';

/// Search-as-you-type for the New Order screen's customer field.
///
/// Copied from [CustomerPickerController].
@ProviderFor(CustomerPickerController)
final customerPickerControllerProvider =
    AutoDisposeNotifierProvider<
      CustomerPickerController,
      PickerState<CustomerOption>
    >.internal(
      CustomerPickerController.new,
      name: r'customerPickerControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$customerPickerControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CustomerPickerController =
    AutoDisposeNotifier<PickerState<CustomerOption>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
