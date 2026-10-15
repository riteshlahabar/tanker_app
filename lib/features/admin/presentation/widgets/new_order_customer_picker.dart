import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/customer_option.dart';
import '../providers/admin_picker_controllers.dart';

/// Search-as-you-type customer field for the New Order form. Picking a
/// result hands the full [CustomerOption] back so the screen can pre-fill
/// address/lat/long.
class NewOrderCustomerPicker extends ConsumerWidget {
  const NewOrderCustomerPicker({super.key, required this.chosen, required this.onChosen});

  final CustomerOption? chosen;
  final ValueChanged<CustomerOption> onChosen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerPickerControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Customer',
            hintText: 'Search by name or mobile',
            border: const OutlineInputBorder(),
            suffixIcon: chosen == null ? null : const Icon(Icons.check_circle, color: Colors.green),
          ),
          onChanged: (value) => ref.read(customerPickerControllerProvider.notifier).search(value),
        ),
        if (state.loading) const LinearProgressIndicator(),
        if (state.options.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final customer in state.options)
                  ListTile(
                    title: Text(customer.fullName),
                    subtitle: Text(customer.mobile ?? ''),
                    onTap: () => onChosen(customer),
                  ),
              ],
            ),
          ),
        if (chosen != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Selected: ${chosen!.fullName}${chosen!.mobile != null ? ' · ${chosen!.mobile}' : ''}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
      ],
    );
  }
}
