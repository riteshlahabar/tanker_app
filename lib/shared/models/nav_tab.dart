import 'package:flutter/material.dart';

/// One branch of a role shell's bottom navigation.
///
/// The shell owns the Scaffold — app bar, drawer and bottom bar — so a tab
/// supplies only its body and what the bar should say. That is what
/// guarantees every screen has an AppBar without each tab remembering to add
/// one, and it keeps the admin drawer reachable from every admin tab.
class NavTab {
  const NavTab({
    required this.label,
    required this.icon,
    required this.title,
    required this.body,
    this.actions = const [],
  });

  final String label;
  final IconData icon;

  /// Shown in the app bar while this tab is selected.
  final String title;

  /// Built once and kept alive by the shell's IndexedStack, so switching tabs
  /// keeps each tab's scroll position and already-loaded list.
  final Widget body;

  final List<Widget> actions;
}
