import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

/// One filter chip, in the design's own language rather than Material's.
///
/// Lifted out of the Driver Expenses filter bar once the reports screen
/// wanted the same control — the second copy is where two bars start drifting
/// into two paddings, the way four private `_Pill`s did before [AdminPill].
///
/// A chip **names its value, not its state**: "Ramesh Patil", not "Driver
/// chosen"; "1 – 27 Oct", not "Date set". A chip that only says a filter is
/// *on* makes the reader open the picker to find out what they are looking
/// at, and the headline above the list becomes unreadable with it.
///
/// Selected takes [colour] where one is given, so a chosen Fuel chip and the
/// Fuel spine on the rows below it are the same blue — the filter and what it
/// filtered read as one thing.
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.colour,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? colour;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = colour ?? appColorPrimary;
    final foreground = selected
        ? (isDark ? Colors.white : accent)
        : (isDark ? Colors.white70 : appTextColorSecondary);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected
            ? accent.withValues(alpha: isDark ? 0.34 : 0.14)
            : (isDark
                ? Theme.of(context).cardColor
                : appetitAppContainerColor.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? accent.withValues(alpha: 0.55) : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 15, color: foreground),
                  const SizedBox(width: 5),
                ] else if (colour != null) ...[
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
