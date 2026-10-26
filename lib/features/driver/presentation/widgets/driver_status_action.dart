import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/order.dart';
import '../../../../shared/models/order_status.dart';
import '../../../../shared/models/spot.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/sheet_body.dart';
import '../providers/driver_order_detail_controller.dart';
import '../providers/driver_providers.dart';

/// The one action that moves the order forward from wherever it currently
/// sits — nothing is shown once it is delivered or cancelled, and there is
/// no Cancel button here: the driver role doesn't carry that permission.
class DriverStatusAction extends ConsumerWidget {
  const DriverStatusAction({super.key, required this.order, required this.acting});

  final Order order;
  final bool acting;

  void _showResult(BuildContext context, String? message) {
    if (message == null) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _startRefill(BuildContext context, WidgetRef ref) async {
    final spots = await ref.read(spotRepositoryProvider).usable();
    final options = spots.valueOrNull ?? const <Spot>[];

    if (!context.mounted) return;

    int? chosenSpotId;
    final noteController = TextEditingController();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => SheetBody(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Start refill', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                // A spot name is as long as the admin typed it; without this the
                // row overflows instead of ellipsizing on a narrow phone.
                isExpanded: true,
                initialValue: chosenSpotId,
                decoration: const InputDecoration(labelText: 'Filling point', border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Use the assigned filling point')),
                  ...options.map((spot) => DropdownMenuItem(value: spot.id, child: Text(spot.name))),
                ],
                onChanged: (value) => setSheetState(() => chosenSpotId = value),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(sheetContext, false),
                    child: const Text('Back'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(sheetContext, true),
                    child: const Text('Start Refill'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) return;

    final message = await ref.read(driverOrderDetailControllerProvider(order.id).notifier).startRefill(
          spotId: chosenSpotId,
          note: noteController.text.trim(),
        );

    if (!context.mounted) return;

    _showResult(context, message);
  }

  Future<void> _markOutForDelivery(BuildContext context, WidgetRef ref) async {
    final message =
        await ref.read(driverOrderDetailControllerProvider(order.id).notifier).markOutForDelivery();

    if (!context.mounted) return;

    _showResult(context, message);
  }

  Future<void> _markDelivered(BuildContext context, WidgetRef ref) async {
    final noteController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as delivered?'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(labelText: 'Note (optional)'),
          maxLines: 2,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Back')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delivered')),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final message = await ref
        .read(driverOrderDetailControllerProvider(order.id).notifier)
        .markDelivered(note: noteController.text.trim());

    if (!context.mounted) return;

    _showResult(context, message);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (label, onPressed) = switch (order.status) {
      OrderStatus.assigned => ('Start Refill', () => _startRefill(context, ref)),
      OrderStatus.refilling => ('Out for Delivery', () => _markOutForDelivery(context, ref)),
      OrderStatus.outForDelivery => ('Mark Delivered', () => _markDelivered(context, ref)),
      OrderStatus.pending || OrderStatus.delivered || OrderStatus.cancelled => (null, null),
    };

    if (label == null) return const SizedBox.shrink();

    return PrimaryButton(label: label, busy: acting, onPressed: onPressed);
  }
}
