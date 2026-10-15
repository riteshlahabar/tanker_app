import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../shared/models/spot.dart';
import 'driver_providers.dart';

part 'nearby_spots_controller.g.dart';

class NearbySpotsState {
  const NearbySpotsState({
    this.spots = const [],
    this.loading = true,
    this.error,
    this.usingFallback = false,
  });

  final List<Spot> spots;
  final bool loading;
  final Failure? error;

  /// True once we fell back to the flat spot list because location was
  /// denied or unavailable — the screen shows a banner explaining why.
  final bool usingFallback;
}

/// Asks the device for its position and shows the nearest spots; falls back
/// to the full usable-spots list rather than a dead screen when location
/// isn't available.
@riverpod
class NearbySpotsController extends _$NearbySpotsController {
  @override
  NearbySpotsState build() {
    unawaited(refresh());

    return const NearbySpotsState();
  }

  Future<void> refresh() async {
    state = const NearbySpotsState();

    final position = await _currentPosition();

    if (position == null) {
      await _loadFallback();

      return;
    }

    final result = await ref.read(spotRepositoryProvider).nearby(
          latitude: position.latitude,
          longitude: position.longitude,
        );

    state = result.when(
      success: (spots) => NearbySpotsState(spots: spots, loading: false),
      error: (_) => state,
    );

    if (state.loading) await _loadFallback();
  }

  Future<void> _loadFallback() async {
    final result = await ref.read(spotRepositoryProvider).usable();

    state = result.when(
      success: (spots) => NearbySpotsState(spots: spots, loading: false, usingFallback: true),
      error: (failure) => NearbySpotsState(loading: false, error: failure, usingFallback: true),
    );
  }

  Future<Position?> _currentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition();
    } catch (_) {
      return null;
    }
  }
}
