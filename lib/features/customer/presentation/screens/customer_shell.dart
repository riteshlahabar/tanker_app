import 'package:flutter/material.dart';

import '../../../../shared/models/nav_tab.dart';
import '../../../../shared/screens/account_profile_screen.dart';
import '../../../../shared/widgets/role_shell.dart';
import 'billing_screen.dart';
import 'customer_home_screen.dart';
import 'my_orders_screen.dart';
import 'place_order_screen.dart';

/// What a customer sees: place an order, follow their own orders, check what
/// they have been billed, manage their account. No drawer — that is the
/// admin's alone.
///
/// The fourth tab was Notifications, which had nothing to show: every real
/// notice goes out over WhatsApp, so the screen listed the customer's orders
/// again under a bell. Billing answers the question they actually open the
/// app with.
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
          label: 'Billing',
          icon: Icons.receipt_long_outlined,
          title: 'My Billing',
          body: BillingScreen(),
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
