import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

/// Active/inactive as a card rather than a bare `SwitchListTile`, saying what
/// being inactive actually *does* — a switch with one word beside it does not.
///
/// The consequence differs per module (a tanker drops out of assignment; a
/// driver can no longer log in), so the two lines are passed in rather than
/// hard-coded, and the dot/track colour reuses the list's own active/inactive
/// greens and reds so the form and the card agree without reading the word.
class ActiveSwitchCard extends StatelessWidget {
  const ActiveSwitchCard({
    super.key,
    required this.value,
    required this.onChanged,
    required this.activeNote,
    required this.inactiveNote,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String activeNote;
  final String inactiveNote;

  @override
  Widget build(BuildContext context) {
    final accent = value ? statusDeliveredColor : statusCancelledColor;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      decoration: BoxDecoration(
        color: appetitAppContainerColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value ? 'Active' : 'Inactive',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  value ? activeNote : inactiveNote,
                  style: const TextStyle(fontSize: 12, color: appTextColorSecondary),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeTrackColor: accent),
        ],
      ),
    );
  }
}
