import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../models/spot.dart';

/// One row of a spot list: name, address, refill charge, and distance when
/// the query was location-based.
class SpotListTile extends StatelessWidget {
  const SpotListTile({super.key, required this.spot});

  final Spot spot;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: appetitAppContainerColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(spot.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    if (spot.distanceKm != null)
                      Text(
                        '${spot.distanceKm!.toStringAsFixed(1)} km',
                        style: const TextStyle(color: appColorPrimary, fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
                if (spot.address != null) ...[
                  const SizedBox(height: 4),
                  Text(spot.address!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('₹ ${spot.refillCharge.toStringAsFixed(0)} refill'),
                    if (spot.contactMobile != null) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.call, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(spot.contactMobile!, style: const TextStyle(fontSize: 13)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (!spot.isAvailable)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.block, color: Colors.red, size: 18),
            ),
        ],
      ),
    );
  }
}
