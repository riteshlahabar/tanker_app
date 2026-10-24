import 'package:flutter/material.dart';

/// The padding every modal bottom sheet's content needs.
///
/// A sheet sits at the bottom of the window, so two different insets can eat
/// its last row — and they are **not** the same thing:
///
/// * `viewInsets.bottom` is the **keyboard**.
/// * `padding.bottom` is the **system navigation bar** (the gesture pill or
///   the three-button bar).
///
/// Every sheet in the app padded for the keyboard alone, which was invisible
/// until Android 15: before it, an app opted out of edge-to-edge and the
/// system drew the bar on its own ground. From Android 15 the opt-out is gone,
/// so the sheet is laid out *under* the navigation bar and its bottom row —
/// typically the Back and confirm buttons — is unreachable.
///
/// Adding both is safe, and that is why `padding` is used rather than
/// `viewPadding`: `padding` is already the navigation-bar inset **minus**
/// whatever the keyboard covers, so when the keyboard is up it falls to zero
/// instead of being counted twice. That is exactly what [SafeArea] applies,
/// expressed as padding so a sheet keeps one widget around its content.
class SheetBody extends StatelessWidget {
  const SheetBody({
    super.key,
    required this.child,
    this.horizontal = 16,
    this.top = 16,
    this.bottom = 16,
  });

  final Widget child;

  /// Left and right inset. The design's sheets all use 16.
  final double horizontal;

  final double top;

  /// Inset below the content, *before* the keyboard and navigation bar are
  /// added to it.
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: horizontal,
        right: horizontal,
        top: top,
        bottom: bottom + MediaQuery.viewInsetsOf(context).bottom + MediaQuery.paddingOf(context).bottom,
      ),
      child: child,
    );
  }
}
