import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/order.dart';
import '../../../../shared/models/order_status.dart';
import '../../../../shared/models/spot.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../providers/driver_order_detail_controller.dart';
import '../providers/driver_providers.dart';
import 'refill_spot_sheet.dart';

/// The one action that moves the order forward from wherever it currently
/// sits — nothing is shown once it is delivered or cancelled, and there is
/// no Cancel button here: the driver role doesn't carry that permission.
///
/// **The filling point is only asked for when it is not already known.** The
/// admin may name a point when assigning the order; when they have, tapping
/// Start Refill starts the refill at that point, and a quieter "Change
/// filling point" link below it covers the driver who finds it shut or
/// queued. Asking again on every order — which is what this widget used to do
/// — made the admin's choice look as though it had not been recorded, and
/// made the common case two taps and a dropdown instead of one tap.
class DriverStatusAction extends ConsumerWidget {
  const DriverStatusAction({super.key, required this.order, required this.acting});

  final Order order;
  final bool acting;

  void _showResult(BuildContext context, String? message) {
    if (message == null) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// The main action at `assigned`.
  ///
  /// With a filling point already on the order this starts the refill
  /// outright and sends **no** `spot_id`, so the point the admin chose — and
  /// the `refill_charge` snapshotted from it — is left exactly as it is.
  Future<void> _startRefill(BuildContext context, WidgetRef ref) async {
    if (order.hasSpot) {
      return _submit(context, ref);
    }

    return _chooseSpot(context, ref, changing: false);
  }

  /// Asks which point, then starts the refill there. Reached by the main
  /// action when the order carries no filling point, and by the Change link
  /// when it does.
  Future<void> _chooseSpot(BuildContext context, WidgetRef ref, {required bool changing}) async {
    final spots = await ref.read(spotRepositoryProvider).usable();

    if (!context.mounted) return;

    final choice = await showRefillSpotSheet(
      context,
      options: spots.valueOrNull ?? const <Spot>[],
      currentSpotId: order.spotId,
      changing: changing,
    );

    if (choice == null || !context.mounted) return;

    return _submit(context, ref, spotId: choice.spotId, note: choice.note);
  }

  Future<void> _submit(BuildContext context, WidgetRef ref, {int? spotId, String? note}) async {
    final message = await ref
        .read(driverOrderDetailControllerProvider(order.id).notifier)
        .startRefill(spotId: spotId, note: note);

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

    // The change link belongs only to the one step it affects: the spot is
    // snapshotted when the refill starts, so once the order is refilling or
    // further on there is nothing left here to change.
    final canChangeSpot = order.status == OrderStatus.assigned && order.hasSpot;

    return Column(
      children: [
        PrimaryButton(label: label, busy: acting, onPressed: onPressed),
        if (canChangeSpot)
          TextButton.icon(
            onPressed: acting ? null : () => _chooseSpot(context, ref, changing: true),
            icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
            label: Text(
              order.spotName == null
                  ? 'Change filling point'
                  : 'Filling at ${order.spotName} · Change',
            ),
          ),
      ],
    );
  }
}
