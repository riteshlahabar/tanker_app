import 'package:flutter/material.dart';

import '../../../../shared/models/nav_tab.dart';
import '../../../../shared/widgets/pending_screen.dart';
import '../../../../shared/widgets/role_shell.dart';
import '../widgets/admin_drawer.dart';

/// What the owner sees. The app mirrors the panel, so the five busiest screens
/// are tabs and the rest of the master data sits in the drawer — the only
/// drawer in the app.
class AdminShell extends StatelessWidget {
  const AdminShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleShell(
      drawer: AdminDrawer(),
      tabs: [
        NavTab(
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          title: 'Dashboard',
          body: PendingScreen(name: 'Dashboard', icon: Icons.dashboard_outlined),
        ),
        NavTab(
          label: 'Orders',
          icon: Icons.receipt_long_outlined,
          title: 'Orders',
          body: PendingScreen(name: 'Orders', icon: Icons.receipt_long_outlined),
        ),
        NavTab(
          label: 'New Order',
          icon: Icons.add_circle_outline,
          title: 'Take an Order',
          body: PendingScreen(name: 'Create an order', icon: Icons.add_circle_outline),
        ),
        NavTab(
          label: 'Reports',
          icon: Icons.bar_chart_outlined,
          title: 'Reports',
          body: PendingScreen(name: 'Reports', icon: Icons.bar_chart_outlined),
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
