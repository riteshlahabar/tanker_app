// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nearby_spots_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$nearbySpotsControllerHash() =>
    r'45f8e2a3f50ed760f945245a807e5bf9028a067d';

/// Asks the device for its position and shows the nearest spots; falls back
/// to the full usable-spots list rather than a dead screen when location
/// isn't available.
///
/// Copied from [NearbySpotsController].
@ProviderFor(NearbySpotsController)
final nearbySpotsControllerProvider =
    AutoDisposeNotifierProvider<
      NearbySpotsController,
      NearbySpotsState
    >.internal(
      NearbySpotsController.new,
      name: r'nearbySpotsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$nearbySpotsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NearbySpotsController = AutoDisposeNotifier<NearbySpotsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
