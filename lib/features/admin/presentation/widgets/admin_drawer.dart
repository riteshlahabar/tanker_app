import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/session_controller.dart';
import '../../../auth/presentation/providers/session_state.dart';
import '../screens/admin_settings_screen.dart';
import '../screens/customer_list_screen.dart';
import '../screens/delivery_slot_list_screen.dart';
import '../screens/driver_list_screen.dart';
import '../screens/schedule_list_screen.dart';
import '../screens/spot_list_screen.dart';
import '../screens/tanker_list_screen.dart';

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
          _DrawerItem(
            icon: Icons.local_shipping_outlined,
            label: 'Tankers',
            screenBuilder: (_) => const TankerListScreen(),
          ),
          _DrawerItem(
            icon: Icons.badge_outlined,
            label: 'Drivers',
            screenBuilder: (_) => const DriverListScreen(),
          ),
          _DrawerItem(
            icon: Icons.people_outline,
            label: 'Customers',
            screenBuilder: (_) => const CustomerListScreen(),
          ),
          _DrawerItem(
            icon: Icons.water_drop_outlined,
            label: 'Refill Spots',
            screenBuilder: (_) => const SpotListScreen(),
          ),
          _DrawerItem(
            icon: Icons.schedule_outlined,
            label: 'Standing Orders',
            screenBuilder: (_) => const ScheduleListScreen(),
          ),
          _DrawerItem(
            icon: Icons.access_time,
            label: 'Delivery Slots',
            screenBuilder: (_) => const DeliverySlotListScreen(),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdminSettingsScreen()),
              );
            },
          ),
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

/// A drawer row. Pass [screenBuilder] once its screen exists; without one it
/// falls back to a "not built yet" snackbar.
class _DrawerItem extends StatelessWidget {
  const _DrawerItem({required this.icon, required this.label, this.screenBuilder});

  final IconData icon;
  final String label;
  final WidgetBuilder? screenBuilder;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.of(context).pop();

        final builder = screenBuilder;

        if (builder == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label is next on the build list.')),
          );

          return;
        }

        Navigator.of(context).push(MaterialPageRoute(builder: builder));
      },
    );
  }
}
