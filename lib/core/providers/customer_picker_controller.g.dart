// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_picker_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$customerPickerControllerHash() =>
    r'346009c6262d73bea7461aa3380d9a349853eeca';

/// Search-as-you-type over customers, for an order form's picker.
///
/// Lives in `core/providers` rather than under a role because both the admin's
/// New Order screen and the driver's read it; the endpoint behind it is chosen
/// by `customerLookupRepositoryProvider` from the signed-in role, so this
/// controller never knows or cares which role is typing.
///
/// A 400 ms debounce keeps a fast typist from firing a request per keystroke,
/// and a blank query resets to empty rather than asking for every customer —
/// the picker is a search box, not a browsable list.
///
/// Copied from [CustomerPickerController].
@ProviderFor(CustomerPickerController)
final customerPickerControllerProvider =
    AutoDisposeNotifierProvider<
      CustomerPickerController,
      CustomerPickerState
    >.internal(
      CustomerPickerController.new,
      name: r'customerPickerControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$customerPickerControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CustomerPickerController = AutoDisposeNotifier<CustomerPickerState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
