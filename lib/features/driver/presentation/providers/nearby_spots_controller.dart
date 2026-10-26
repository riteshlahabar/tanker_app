import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/providers/first_load.dart';
import '../../../../shared/models/spot.dart';
import 'driver_providers.dart';

part 'nearby_spots_controller.g.dart';

class NearbySpotsState {
  const NearbySpotsState({this.spots = const [], this.loading = true, this.error});

  final List<Spot> spots;
  final bool loading;
  final Failure? error;
}

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
@riverpod
class NearbySpotsController extends _$NearbySpotsController {
  @override
  NearbySpotsState build() {
    FirstLoad.after(ref, refresh);

    return const NearbySpotsState();
  }

  Future<void> refresh() async {
    state = const NearbySpotsState();

    final result = await ref.read(spotRepositoryProvider).usable();

    state = result.when(
      success: (spots) => NearbySpotsState(spots: spots, loading: false),
      error: (failure) => NearbySpotsState(loading: false, error: failure),
    );
  }
}
