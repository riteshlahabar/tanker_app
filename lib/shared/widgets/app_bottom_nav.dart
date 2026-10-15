import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../models/nav_tab.dart';

/// The design's bottom bar, lifted from appetit's dashboard: 25px icons on the
/// dark plum ground, orange accent for the selected tab, labels hidden.
///
/// Every role shell uses this one widget, so the three shells cannot drift
/// apart visually.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
  });

  final List<NavTab> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const Color background = appBottomNavColor;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      iconSize: 25,
      backgroundColor: background,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      showUnselectedLabels: false,
      showSelectedLabels: false,
      onTap: onTap,
      elevation: 0,
      unselectedItemColor: Colors.white,
      selectedItemColor: Colors.orangeAccent,
      items: tabs
          .map(
            (tab) => BottomNavigationBarItem(
              icon: Icon(tab.icon),
              label: tab.label,
              tooltip: tab.label,
            ),
          )
          .toList(growable: false),
    );
  }
}
