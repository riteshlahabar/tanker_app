// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nearby_spots_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$nearbySpotsControllerHash() =>
    r'bd55b85a82738a903e4dc756f38833579f2e886e';

/// The filling points a driver can refill at, by name.
///
/// It used to ask the device for a position and sort the points by distance
/// from it. That is gone with the coordinates: nothing ever filled a point's
/// latitude and longitude in, so the nearest-first query filtered every point
/// out and the screen fell through to this same flat list on every run — the
/// fallback was the feature. A driver finds a point by its address and rings
/// the contact mobile, both of which are now required on every one.
///
/// The class and provider names are kept so the generated `.g.dart` stays
/// valid; only what it does has changed.
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
