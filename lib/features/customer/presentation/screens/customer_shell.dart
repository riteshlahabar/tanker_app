import 'package:flutter/material.dart';

import '../../../../shared/models/nav_tab.dart';
import '../../../../shared/widgets/role_shell.dart';
import 'customer_home_screen.dart';
import 'my_orders_screen.dart';
import 'notifications_screen.dart';
import 'place_order_screen.dart';
import 'profile_screen.dart';

/// What a customer sees: place an order, follow their own orders, read
/// notices, manage their account. No drawer — that is the admin's alone.
class CustomerShell extends StatelessWidget {
  const CustomerShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleShell(
      tabs: [
        NavTab(
          label: 'Home',
          icon: Icons.home,
          title: 'Tanker',
          body: CustomerHomeScreen(),
        ),
        NavTab(
          label: 'Order',
          icon: Icons.add_circle_outline,
          title: 'Book a Tanker',
          body: PlaceOrderScreen(),
        ),
        NavTab(
          label: 'My Orders',
          icon: Icons.receipt_long_outlined,
          title: 'My Orders',
          body: MyOrdersScreen(),
        ),
        NavTab(
          label: 'Notifications',
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          body: NotificationsScreen(),
        ),
        NavTab(
          label: 'Profile',
          icon: Icons.person_outline,
          title: 'My Profile',
          body: ProfileScreen(),
        ),
      ],
    );
  }
}
