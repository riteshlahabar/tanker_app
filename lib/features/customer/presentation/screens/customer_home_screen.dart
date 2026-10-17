import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/presentation/providers/session_controller.dart';
import '../../../auth/presentation/providers/session_state.dart';
import '../providers/my_orders_controller.dart';
import '../providers/my_schedule_controller.dart';
import '../widgets/home_order_summary_card.dart';
import '../widgets/home_schedule_card.dart';
import 'book_tanker_screen.dart';
import 'my_deliveries_screen.dart';
import 'order_detail_screen.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final user = session is SessionSignedIn ? session.user : null;
    final scheduleState = ref.watch(myScheduleControllerProvider);
    final ongoing = ref.watch(myOrdersControllerProvider(true));

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(myScheduleControllerProvider.notifier).refresh();
        await ref.read(myOrdersControllerProvider(true).notifier).refresh();
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Hello, ${user?.firstName ?? ''}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 16),
          if (scheduleState.data?.schedule != null)
            HomeScheduleCard(
              schedule: scheduleState.data!.schedule!,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyDeliveriesScreen()),
              ),
            ),
          if (ongoing.paginated.items.isNotEmpty)
            HomeOrderSummaryCard(
              order: ongoing.paginated.items.first,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OrderDetailScreen(orderId: ongoing.paginated.items.first.id),
                ),
              ),
            ),
          if (user?.canSelfOrder ?? true)
            Padding(
              padding: const EdgeInsets.all(16),
              child: PrimaryButton(
                label: 'Book a Tanker',
                icon: Icons.add_circle_outline,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BookTankerScreen()),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
