import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_result.dart';
import '../../../../shared/models/spot.dart';
import '../../../../shared/widgets/sheet_body.dart';
import '../../../driver/presentation/providers/driver_providers.dart' as driver;
import '../../domain/driver_option.dart';
import '../providers/admin_order_detail_controller.dart';
import '../providers/admin_picker_controllers.dart';

/// Changing the driver on an order that already has one — the absent-driver
/// case, and the only way a standing order's preferred driver can be
/// overridden for a single day without cancelling the order.
///
/// Kept separate from [AssignOrderSheet] rather than given a mode flag: the
/// wording is different, the driver who holds the order is excluded from the
/// list, the spot default means "keep the current one" instead of "none", and
/// it carries a reason the first assignment has no use for.
class ReassignOrderSheet extends ConsumerStatefulWidget {
  const ReassignOrderSheet({
    super.key,
    required this.orderId,
    required this.currentDriverId,
    this.currentDriverName,
    this.isStandingOrder = false,
  });

  final int orderId;

  /// Excluded from the list, since the server refuses handing an order to the
  /// driver who already has it.
  final int? currentDriverId;

  final String? currentDriverName;

  /// Shows the note that only this day changes, not the routine.
  final bool isStandingOrder;

  @override
  ConsumerState<ReassignOrderSheet> createState() => _ReassignOrderSheetState();
}

class _ReassignOrderSheetState extends ConsumerState<ReassignOrderSheet> {
  final _reason = TextEditingController();
  DriverOption? _chosenDriver;
  int? _chosenSpotId;
  List<Spot> _spotOptions = const [];

  @override
  void initState() {
    super.initState();
    _loadSpots();
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _loadSpots() async {
    final ApiResult<List<Spot>> result = await ref.read(driver.spotRepositoryProvider).usable();

    if (!mounted) return;

    setState(() => _spotOptions = result.valueOrNull ?? const []);
  }

  @override
  Widget build(BuildContext context) {
    final driverState = ref.watch(driverPickerControllerProvider);

    final choices = driverState.options
        .where((option) => option.id != widget.currentDriverId)
        .toList(growable: false);

    return SheetBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Change driver', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 6),
          Text(
            widget.currentDriverName == null
                ? 'They will be told the order has moved.'
                : 'Currently with ${widget.currentDriverName}. '
                    'They will be told the order has moved.',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          if (widget.isStandingOrder) ...[
            const SizedBox(height: 6),
            const Text(
              'Only this delivery changes — the routine keeps its usual driver.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(labelText: 'Search drivers'),
            onChanged: (value) => ref.read(driverPickerControllerProvider.notifier).search(value),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final driverOption in choices)
                  ListTile(
                    selected: _chosenDriver?.id == driverOption.id,
                    leading: Icon(
                      _chosenDriver?.id == driverOption.id
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                    ),
                    title: Text(driverOption.fullName),
                    subtitle: driverOption.hasTanker ? null : const Text('No tanker assigned'),
                    onTap: () => setState(() => _chosenDriver = driverOption),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int?>(
            // A spot name is as long as the admin typed it; without this the
            // row overflows instead of ellipsizing on a narrow phone.
            isExpanded: true,
            initialValue: _chosenSpotId,
            decoration: const InputDecoration(labelText: 'Filling point'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Keep the current filling point')),
              ..._spotOptions.map((spot) => DropdownMenuItem(value: spot.id, child: Text(spot.name))),
            ],
            onChanged: (value) => setState(() => _chosenSpotId = value),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reason,
            decoration: const InputDecoration(labelText: 'Reason', hintText: 'Driver absent'),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back')),
              FilledButton(
                onPressed: _chosenDriver == null ? null : () => _submit(context),
                child: const Text('Change driver'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final reason = _reason.text.trim();

    final message = await ref
        .read(adminOrderDetailControllerProvider(widget.orderId).notifier)
        .reassign(
          driverId: _chosenDriver!.id,
          spotId: _chosenSpotId,
          reason: reason.isEmpty ? null : reason,
        );

    if (!context.mounted) return;

    Navigator.pop(context);

    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
