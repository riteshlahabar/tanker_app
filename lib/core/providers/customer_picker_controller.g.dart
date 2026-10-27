// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_picker_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$customerPickerControllerHash() =>
    r'1e8fd7ee5c93b6c04835b0e73d24739f945cffdc';

/// The customer list behind an order form's picker, searchable as you type.
///
/// Lives in `core/providers` rather than under a role because both the admin's
/// New Order screen and the driver's read it; the endpoint behind it is chosen
/// by `customerLookupRepositoryProvider` from the signed-in role, so this
/// controller never knows or cares which role is typing.
///
/// **Opening it with nothing typed lists every customer** — the owner asked
/// for a dropdown you *can* search, not a search box that hides the book until
/// you guess a name. The unfiltered page is cached for the life of the
/// provider, so reopening the field is instant and a browse costs one request
/// per visit rather than one per tap. A 400 ms debounce still keeps a fast
/// typist from firing a request per keystroke.
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
