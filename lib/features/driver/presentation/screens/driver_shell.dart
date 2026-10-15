import 'package:flutter/material.dart';

import '../../../../shared/models/nav_tab.dart';
import '../../../../shared/widgets/pending_screen.dart';
import '../../../../shared/widgets/role_shell.dart';

/// What a driver sees: today's run, their deliveries, the refill spots on the
/// route, what they have earned, and their account. No drawer.
class DriverShell extends StatelessWidget {
  const DriverShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleShell(
      tabs: [
        NavTab(
          label: 'Home',
          icon: Icons.home,
          title: "Today's Deliveries",
          body: PendingScreen(name: 'Home', icon: Icons.home_outlined),
        ),
        NavTab(
          label: 'Orders',
          icon: Icons.local_shipping_outlined,
          title: 'My Deliveries',
          body: PendingScreen(name: 'My deliveries', icon: Icons.local_shipping_outlined),
        ),
        NavTab(
          label: 'Spots',
          icon: Icons.water_drop_outlined,
          title: 'Refill Spots',
          body: PendingScreen(name: 'Nearby spots', icon: Icons.water_drop_outlined),
        ),
        NavTab(
          label: 'Earnings',
          icon: Icons.currency_rupee,
          title: 'My Earnings',
          body: PendingScreen(name: 'My earnings', icon: Icons.currency_rupee),
        ),
        NavTab(
          label: 'Profile',
          icon: Icons.person_outline,
          title: 'My Profile',
          body: PendingScreen(name: 'Profile', icon: Icons.person_outline),
        ),
      ],
    );
  }
}
