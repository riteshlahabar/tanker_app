import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../providers/my_schedule_controller.dart';
import '../../../../shared/widgets/upcoming_date_tile.dart';

/// Pushed from the Home schedule card. Lists the next ~14 dates of the
/// customer's routine with a Skip/Restore button each — the "My Deliveries"
/// screen the owner asked for.
class MyDeliveriesScreen extends ConsumerWidget {
  const MyDeliveriesScreen({super.key});

  Future<void> _skip(BuildContext context, WidgetRef ref, DateTime date) async {
    final reasonController = TextEditingController();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Skip this delivery?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Reason (optional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Back')),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Skip delivery'),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final message = await ref.read(myScheduleControllerProvider.notifier).skip(
          date,
          reasonController.text.trim().isEmpty ? null : reasonController.text.trim(),
        );

    if (!context.mounted || message == null) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _restore(BuildContext context, WidgetRef ref, DateTime date) async {
    final message = await ref.read(myScheduleControllerProvider.notifier).restore(date);

    if (!context.mounted || message == null) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myScheduleControllerProvider);
    final schedule = state.data?.schedule;

    return Scaffold(
      appBar: AppBar(title: const Text('My Deliveries')),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : schedule == null
              ? const EmptyState(
                  icon: Icons.event_busy,
                  title: 'No routine on file',
                  message: 'You are not on a delivery routine.',
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(myScheduleControllerProvider.notifier).refresh(),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(schedule.pattern, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 8),
                      for (final date in state.data!.upcoming)
                        UpcomingDateTile(
                          date: date,
                          busy: state.busyDate == date.date,
                          onSkip: () => _skip(context, ref, date.date),
                          onRestore: () => _restore(context, ref, date.date),
                        ),
                    ],
                  ),
                ),
    );
  }
}
