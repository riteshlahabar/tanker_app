// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_picker_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$driverPickerControllerHash() =>
    r'e4efdccb46629e1a4622e10538423a6adedf7300';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
