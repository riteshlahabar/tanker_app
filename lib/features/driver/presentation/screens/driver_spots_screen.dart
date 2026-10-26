import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/spot_list_tile.dart';
import '../providers/nearby_spots_controller.dart';

/// Spots tab body — every filling point a driver may refill at, by name.
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
          for (final spot in state.spots) SpotListTile(spot: spot),
        ],
      ),
    );
  }
}
