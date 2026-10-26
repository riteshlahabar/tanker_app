import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/spot_list_tile.dart';
import '../providers/nearby_spots_controller.dart';

/// Spots tab body — nearest-first when location is available, the flat
/// usable-spots list with an explanatory banner when it isn't.
class DriverSpotsScreen extends ConsumerWidget {
  const DriverSpotsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nearbySpotsControllerProvider);

    if (state.loading) return const Center(child: CircularProgressIndicator());

    if (state.spots.isEmpty) {
      return EmptyState(
        icon: Icons.water_drop_outlined,
        title: 'No filling points available',
        message: state.error?.message,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(nearbySpotsControllerProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          if (state.usingFallback)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Showing all filling points — enable location to see the nearest ones first.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          for (final spot in state.spots) SpotListTile(spot: spot),
        ],
      ),
    );
  }
}
