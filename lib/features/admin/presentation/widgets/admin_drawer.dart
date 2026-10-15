import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/session_controller.dart';
import '../../../auth/presentation/providers/session_state.dart';

/// The owner's drawer — the master data and reports that do not earn a place
/// in the five-tab bar. Admin only; the driver and customer shells pass no
/// drawer at all.
class AdminDrawer extends ConsumerWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final user = session is SessionSignedIn ? session.user : null;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.fullName ?? 'Owner'),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user?.initials ?? '?',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const _DrawerItem(icon: Icons.local_shipping_outlined, label: 'Tankers'),
          const _DrawerItem(icon: Icons.badge_outlined, label: 'Drivers'),
          const _DrawerItem(icon: Icons.people_outline, label: 'Customers'),
          const _DrawerItem(icon: Icons.water_drop_outlined, label: 'Refill Spots'),
          const _DrawerItem(icon: Icons.schedule_outlined, label: 'Standing Orders'),
          const _DrawerItem(icon: Icons.access_time, label: 'Delivery Slots'),
          const Divider(),
          const _DrawerItem(icon: Icons.bar_chart_outlined, label: 'Reports'),
          const _DrawerItem(icon: Icons.settings_outlined, label: 'Settings'),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () {
              Navigator.of(context).pop();
              ref.read(sessionControllerProvider.notifier).signOut();
            },
          ),
        ],
      ),
    );
  }
}

/// A drawer row whose screen arrives with the admin phase.
class _DrawerItem extends StatelessWidget {
  const _DrawerItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label is next on the build list.')),
        );
      },
    );
  }
}
