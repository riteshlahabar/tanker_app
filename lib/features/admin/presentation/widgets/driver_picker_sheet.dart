import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/sheet_body.dart';
import '../../domain/driver_option.dart';
import '../providers/admin_picker_controllers.dart';

/// Search-and-choose a driver, returning the chosen [DriverOption].
///
/// Shared by the New Order screen and the standing-order form, which ask the
/// same question for the same reason: the driver's tanker is what prices the
/// delivery. So each row shows the vehicle and what a load from it costs —
/// without that, choosing a driver silently decides the price.
///
/// A driver holding no tanker cannot take an order at all, which the server
/// refuses on assignment; the row says so and is not tappable, rather than
/// letting the admin fill the form in and be told at the end.
class DriverPickerSheet extends ConsumerWidget {
  const DriverPickerSheet({super.key, this.title = 'Choose a driver'});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(driverPickerControllerProvider);

    return SheetBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),
          TextField(
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Search drivers'),
            onChanged: (value) => ref.read(driverPickerControllerProvider.notifier).search(value),
          ),
          const SizedBox(height: 12),
          if (state.loading) const LinearProgressIndicator(),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                state.error!.message,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          // Flexible plus a shrink-wrapped list: the sheet grows with the
          // results instead of being clipped at a fixed height.
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final driver in state.options) _DriverRow(driver: driver),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverRow extends StatelessWidget {
  const _DriverRow({required this.driver});

  final DriverOption driver;

  @override
  Widget build(BuildContext context) {
    final rate = driver.tankerRate ?? 0;

    return ListTile(
      enabled: driver.hasTanker,
      leading: CircleAvatar(
        child: Text(driver.fullName.isEmpty ? '?' : driver.fullName.substring(0, 1).toUpperCase()),
      ),
      title: Text(driver.fullName),
      subtitle: Text(
        !driver.hasTanker
            ? 'No tanker assigned — cannot take an order'
            : rate > 0
                ? '${driver.tankerLabel} · ₹ ${rate.toStringAsFixed(0)} per tanker'
                : '${driver.tankerLabel} · no rate set on this tanker',
      ),
      onTap: driver.hasTanker ? () => Navigator.pop(context, driver) : null,
    );
  }
}
