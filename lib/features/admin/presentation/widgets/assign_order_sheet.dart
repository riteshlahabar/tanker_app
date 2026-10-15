import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_result.dart';
import '../../../../shared/models/spot.dart';
import '../../../driver/presentation/providers/driver_providers.dart' as driver;
import '../../domain/driver_option.dart';
import '../providers/admin_order_detail_controller.dart';
import '../providers/admin_picker_controllers.dart';

/// Driver search + optional spot override, submitted through
/// `AdminOrderDetailController.assign`.
class AssignOrderSheet extends ConsumerStatefulWidget {
  const AssignOrderSheet({super.key, required this.orderId});

  final int orderId;

  @override
  ConsumerState<AssignOrderSheet> createState() => _AssignOrderSheetState();
}

class _AssignOrderSheetState extends ConsumerState<AssignOrderSheet> {
  DriverOption? _chosenDriver;
  int? _chosenSpotId;
  List<Spot> _spotOptions = const [];

  @override
  void initState() {
    super.initState();
    _loadSpots();
  }

  Future<void> _loadSpots() async {
    final ApiResult<List<Spot>> result = await ref.read(driver.spotRepositoryProvider).usable();

    if (!mounted) return;

    setState(() => _spotOptions = result.valueOrNull ?? const []);
  }

  @override
  Widget build(BuildContext context) {
    final driverState = ref.watch(driverPickerControllerProvider);

    return Padding(
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
          const Text('Assign a driver', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(labelText: 'Search drivers'),
            onChanged: (value) => ref.read(driverPickerControllerProvider.notifier).search(value),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final driverOption in driverState.options)
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
            initialValue: _chosenSpotId,
            decoration: const InputDecoration(labelText: 'Refill spot (optional)'),
            items: [
              const DropdownMenuItem(value: null, child: Text('No override')),
              ..._spotOptions.map((spot) => DropdownMenuItem(value: spot.id, child: Text(spot.name))),
            ],
            onChanged: (value) => setState(() => _chosenSpotId = value),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              FilledButton(
                onPressed: _chosenDriver == null ? null : () => _submit(context),
                child: const Text('Assign'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final message = await ref
        .read(adminOrderDetailControllerProvider(widget.orderId).notifier)
        .assign(driverId: _chosenDriver!.id, spotId: _chosenSpotId);

    if (!context.mounted) return;

    Navigator.pop(context);

    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
