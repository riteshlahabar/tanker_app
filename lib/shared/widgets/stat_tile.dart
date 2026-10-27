import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

/// A labelled number — one counter on a dashboard or report.
///
/// The shape is appetit's own stat block (`AProfileFragment`): a 15px-radius
/// container with a heavy value over a small light label. What is added here
/// is the per-tile [color], which tints the card and the value, and the
/// optional [icon] that sits as a faint accent beside the figure.
///
/// Every colour passed in comes from `core/theme/colors.dart` — the design's
/// palette and the status colours already mapped onto it — so a tile never
/// introduces a hue the rest of the app does not use. A Pending tile is the
/// same amber as a Pending chip, and Delivered the same green.
///
/// Built to survive a fixed-height cell: the dashboard puts these in a
/// `GridView` where the cell height comes from an aspect ratio, so a long
/// label or a large money value must shrink rather than overflow. The value
/// scales down to the tile width instead of wrapping — a split "₹ 1,20," over
/// "000" reads as nonsense.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.color,
    this.icon,
    this.onTap,
  });

  final String label;
  final String value;

  /// Null keeps the plain cream card the report screen's totals use, where a
  /// dozen tiles in a row would be noise if each were tinted.
  final Color? color;
  final IconData? icon;

  /// Optional: where the figure comes from. A dashboard counter is a question
  /// — "nine orders today, which nine?" — so the tile answers it by opening
  /// the list it was counted from. A report total has no such list behind it
  /// and passes nothing, staying a plain card.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? appColorPrimary;
    const radius = 15.0;
    const padding = EdgeInsets.symmetric(horizontal: 14, vertical: 11);

    final decoration = BoxDecoration(
      color: color == null
          ? appetitAppContainerColor.withValues(alpha: 0.5)
          : color!.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(radius),
      border: color == null ? null : Border.all(color: color!.withValues(alpha: 0.18)),
    );

    final content = Column(
        // min, not max: in a Wrap (the report screen) the height is unbounded,
        // and a max column there would try to be infinitely tall.
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: accent,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 6),
                Icon(icon, size: 18, color: accent.withValues(alpha: 0.45)),
              ],
            ],
          ),
          const SizedBox(height: 3),
          Text(
            label,
            // One line on the dashboard, where every cell is the same height;
            // two where the height is free, so a wordy report total still reads.
            maxLines: icon == null ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: appTextColorSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );

    if (onTap == null) {
      return Container(padding: padding, decoration: decoration, child: content);
    }

    // `Ink` rather than a decorated `Container`: a Container's own colour sits
    // above the Material the splash is painted on, so the tap feedback would
    // be invisible — the same trap the customer picker's ListTile hit.
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: decoration,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Padding(padding: padding, child: content),
        ),
      ),
    );
  }
}
