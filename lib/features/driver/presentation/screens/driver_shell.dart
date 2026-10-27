import 'package:flutter/material.dart';

import '../../../../shared/models/nav_tab.dart';
import '../../../../shared/screens/account_profile_screen.dart';
import '../../../../shared/widgets/role_shell.dart';
import 'driver_expenses_screen.dart';
import 'driver_home_screen.dart';
import 'driver_new_order_screen.dart';
import 'driver_orders_screen.dart';
import 'driver_spots_screen.dart';

/// What a driver sees: today's run, their deliveries, the refill spots on the
/// route, what they have spent, and their account. No drawer.
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
        // Third, exactly where the admin shell puts its own New Order tab —
        // the owner asked for the same thing a driver sees. A sixth icon costs
        // nothing in the bar because AppBottomNav hides every label.
        NavTab(
          label: 'New Order',
          icon: Icons.add_circle_outline,
          title: 'Take an Order',
          body: DriverNewOrderScreen(),
        ),
        NavTab(
          label: 'Filling',
          icon: Icons.water_drop_outlined,
          title: 'Filling Points',
          body: DriverSpotsScreen(),
        ),
        NavTab(
          label: 'Expenses',
          icon: Icons.receipt_long_outlined,
          title: 'My Expenses',
          body: DriverExpensesScreen(),
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
