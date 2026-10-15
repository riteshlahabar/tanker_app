import 'package:flutter/material.dart';

import '../../../../shared/models/nav_tab.dart';
import '../../../../shared/screens/account_profile_screen.dart';
import '../../../../shared/widgets/role_shell.dart';
import 'driver_earnings_screen.dart';
import 'driver_home_screen.dart';
import 'driver_orders_screen.dart';
import 'driver_spots_screen.dart';

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
          body: DriverHomeScreen(),
        ),
        NavTab(
          label: 'Orders',
          icon: Icons.local_shipping_outlined,
          title: 'My Deliveries',
          body: DriverOrdersScreen(),
        ),
        NavTab(
          label: 'Spots',
          icon: Icons.water_drop_outlined,
          title: 'Refill Spots',
          body: DriverSpotsScreen(),
        ),
        NavTab(
          label: 'Earnings',
          icon: Icons.currency_rupee,
          title: 'My Earnings',
          body: DriverEarningsScreen(),
        ),
        NavTab(
          label: 'Profile',
          icon: Icons.person_outline,
          title: 'My Profile',
          body: AccountProfileScreen(),
        ),
      ],
    );
  }
}
