import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/customer_picker_controller.dart';
import '../../core/theme/colors.dart';
import '../models/customer_option.dart';

/// Search-and-choose the customer an order is for.
///
/// Shared by the admin's New Order screen and the driver's: the same question,
/// the same shape back, and `customerLookupRepositoryProvider` decides which
/// endpoint the session is allowed to ask.
///
/// Drawn as the app's own borderless cream field rather than the outlined box
/// it used to be — it sits at the top of a column of `AppTextField`s and
/// `AppDropdownField`s, and an `OutlineInputBorder` there was the one grey
/// rectangle on the form. Choosing a result collapses the list and shows the
/// customer as a cream card, so the chosen name survives scrolling away.
class CustomerPickerField extends ConsumerStatefulWidget {
  const CustomerPickerField({super.key, required this.chosen, required this.onChosen});

  final CustomerOption? chosen;
  final ValueChanged<CustomerOption> onChosen;

  @override
  ConsumerState<CustomerPickerField> createState() => _CustomerPickerFieldState();
}

class _CustomerPickerFieldState extends ConsumerState<CustomerPickerField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _choose(CustomerOption customer) {
    widget.onChosen(customer);

    // The name is shown on the card below, so leaving the query in the box and
    // the list open would say the same thing three times.
    _controller.clear();
    ref.read(customerPickerControllerProvider.notifier).dismiss();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerPickerControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? Theme.of(context).cardColor : appetitAppContainerColor;
    final chosen = widget.chosen;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            onChanged: (value) =>
                ref.read(customerPickerControllerProvider.notifier).search(value),
            decoration: InputDecoration(
              labelText: 'Customer',
              labelStyle: const TextStyle(color: Colors.grey),
              hintText: 'Search by name or mobile',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13.5),
              prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
              border: InputBorder.none,
              filled: true,
              fillColor: fill.withValues(alpha: isDark ? 1 : 0.6),
            ),
          ),
        ),
        if (state.loading)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: LinearProgressIndicator(minHeight: 2),
          ),
        if (state.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              state.error!.message,
              style: TextStyle(fontSize: 12.5, color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (state.options.isNotEmpty) _results(state.options, fill),
        if (chosen != null && state.options.isEmpty) _chosenCard(chosen, fill),
      ],
    );
  }

  /// Capped and scrollable: a common surname can match dozens of customers,
  /// and an uncapped list would push the whole form off the screen.
  Widget _results(List<CustomerOption> options, Color fill) => Container(
        margin: const EdgeInsets.only(top: 6),
        constraints: const BoxConstraints(maxHeight: 220),
        // A Material rather than a coloured Container: a ListTile paints its
        // background and ink on the nearest Material ancestor, so a decorated
        // box between the two hides the tap feedback — Flutter asserts on it.
        child: Material(
          color: fill.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(13),
          clipBehavior: Clip.antiAlias,
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final customer = options[index];

              return ListTile(
                dense: true,
                title: Text(
                  customer.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                subtitle: Text(
                  [?customer.mobile, ?customer.address].join('  ·  '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: appTextColorSecondary),
                ),
                onTap: () => _choose(customer),
              );
            },
          ),
        ),
      );

  Widget _chosenCard(CustomerOption customer, Color fill) => Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: fill.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, size: 20, color: Colors.green),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  if (customer.mobile != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      customer.mobile!,
                      style: const TextStyle(fontSize: 12, color: appTextColorSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
}
