import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../../../auth/presentation/providers/session_controller.dart';
import '../../../auth/presentation/providers/session_state.dart';
import '../screens/admin_expense_list_screen.dart';
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
          _DrawerHeader(
            name: user?.fullName ?? 'Owner',
            email: user?.email ?? '',
            initials: user?.initials ?? '?',
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
            label: 'Filling Points',
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
          _DrawerItem(
            icon: Icons.receipt_long_outlined,
            label: 'Driver Expenses',
            screenBuilder: (_) => const AdminExpenseListScreen(),
          ),
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

/// Account strip at the top of the drawer.
///
/// Deliberately not `UserAccountsDrawerHeader`: that stacks the avatar above
/// the name and runs to ~160px, which pushed the menu itself off a short
/// phone. This is one row — avatar, then name over email — at roughly half
/// the height. The plum is the app bar's and the bottom bar's, so the three
/// read as one piece.
class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.name, required this.email, required this.initials});

  final String name;
  final String email;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: appBottomNavColor,
      // The status bar sits behind the drawer, so the top inset is padding
      // here rather than a SafeArea that would add a second gap.
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 14, 16, 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: appBottomNavColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (email.isNotEmpty)
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
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
