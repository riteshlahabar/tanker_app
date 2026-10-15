import 'package:flutter/material.dart';

import 'empty_state.dart';

/// A tab whose screen belongs to a later phase. It is a real screen inside the
/// shell — bar, bottom bar and back behaviour all work — so the navigation can
/// be walked and tested before the content lands.
class PendingScreen extends StatelessWidget {
  const PendingScreen({super.key, required this.name, required this.icon});

  final String name;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: icon,
      title: name,
      message: 'This screen is next on the build list.',
    );
  }
}
