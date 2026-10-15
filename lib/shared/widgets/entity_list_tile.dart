import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

/// One row of a master-data list (Tanker/Driver/Customer/Spot) — a title, an
/// optional subtitle, and a status dot. The four CRUD lists share this
/// instead of four near-identical tiles.
class EntityListTile extends StatelessWidget {
  const EntityListTile({
    super.key,
    required this.title,
    required this.active,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
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
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ],
              ),
            ),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: active ? statusDeliveredColor : statusCancelledColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
