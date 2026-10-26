import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/sheet_body.dart';
import '../../../../shared/widgets/shell_tab_bar.dart';
import '../../../../shared/widgets/upcoming_date_tile.dart';
import '../providers/admin_schedule_detail_controller.dart';
import 'schedule_form_screen.dart';

/// A standing order's own fields, read-only, plus its upcoming dates with
/// Skip/Restore — the admin overrides the six-hour notice, but the
/// `can_skip` flag already encodes that because the server computes it
/// against whoever is asking, so this button logic is identical to the
/// customer's own "My Deliveries" screen.
class ScheduleDetailScreen extends ConsumerWidget {
  const ScheduleDetailScreen({super.key, required this.scheduleId});

  final int scheduleId;

  static final _dateFormat = DateFormat('d MMM yyyy');

  Future<void> _skip(BuildContext context, WidgetRef ref, DateTime date) async {
    final reasonController = TextEditingController();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SheetBody(
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

    final message = await ref.read(adminScheduleDetailControllerProvider(scheduleId).notifier).skip(
          date,
          reasonController.text.trim().isEmpty ? null : reasonController.text.trim(),
        );

    if (!context.mounted || message == null) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _restore(BuildContext context, WidgetRef ref, DateTime date) async {
    final message =
        await ref.read(adminScheduleDetailControllerProvider(scheduleId).notifier).restore(date);

    if (!context.mounted || message == null) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminScheduleDetailControllerProvider(scheduleId));
    final detail = state.detail;

    return Scaffold(
      appBar: AppBar(
        title: Text(detail?.schedule.customerName ?? 'Standing Order'),
        actions: [
          if (detail != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ScheduleFormScreen(existing: detail.schedule),
                ),
              ),
            ),
        ],
      ),
      body: state.loading && detail == null
          ? const Center(child: CircularProgressIndicator())
          : detail == null
              ? EmptyState(
                  icon: Icons.error_outline,
                  title: 'Could not load this standing order',
                  message: state.error?.message,
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(adminScheduleDetailControllerProvider(scheduleId).notifier).refresh(),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _detailRow(Icons.repeat, detail.schedule.pattern),
                      if (detail.schedule.deliveryAddress != null)
                        _detailRow(Icons.location_on_outlined, detail.schedule.deliveryAddress!),
                      if (detail.schedule.tankerCount != null)
                        _detailRow(Icons.water_drop_outlined, detail.schedule.tankerLabel),
                      _detailRow(
                        Icons.currency_rupee,
                        detail.schedule.tankerRate == null
                            ? 'Priced from the tanker that delivers'
                            : '₹ ${detail.schedule.tankerRate!.toStringAsFixed(0)} per tanker · '
                                '₹ ${detail.schedule.amountPerDelivery!.toStringAsFixed(0)} per delivery',
                      ),
                      if (detail.schedule.preferredDriver != null)
                        _detailRow(Icons.local_shipping_outlined,
                            'Preferred driver: ${detail.schedule.preferredDriver}'),
                      if (detail.schedule.startDate != null)
                        _detailRow(
                          Icons.calendar_today_outlined,
                          'From ${_dateFormat.format(detail.schedule.startDate!)}'
                          '${detail.schedule.endDate != null ? ' to ${_dateFormat.format(detail.schedule.endDate!)}' : ''}',
                        ),
                      if (detail.schedule.isPaused)
                        _detailRow(Icons.pause_circle_outline, 'Paused'),
                      if (detail.schedule.notes != null && detail.schedule.notes!.isNotEmpty)
                        _detailRow(Icons.notes_outlined, detail.schedule.notes!),
                      const SizedBox(height: 24),
                      const Text('Upcoming deliveries',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 8),
                      for (final date in detail.upcoming)
                        UpcomingDateTile(
                          date: date,
                          busy: state.busyDate == date.date,
                          onSkip: () => _skip(context, ref, date.date),
                          onRestore: () => _restore(context, ref, date.date),
                        ),
                    ],
                  ),
                ),
      bottomNavigationBar: const ShellTabBar(),
    );
  }

  Widget _detailRow(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: Colors.grey),
            const SizedBox(width: 10),
            Expanded(child: Text(text)),
          ],
        ),
      );
}
