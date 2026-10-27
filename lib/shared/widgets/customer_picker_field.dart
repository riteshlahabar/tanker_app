import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/customer_picker_controller.dart';
import '../../core/theme/colors.dart';
import '../models/customer_option.dart';

/// Choose the customer an order is for — a dropdown first, a search second.
///
/// Shared by the admin's New Order screen, the driver's and the schedule form:
/// the same question, the same shape back, and
/// `customerLookupRepositoryProvider` decides which endpoint the session is
/// allowed to ask.
///
/// **Tapping it lists every customer.** It used to show nothing until
/// something was typed, which asked whoever was writing the order to already
/// know a name or a mobile — no use to a driver taking down a job from
/// somebody who says "the usual flat in Kothrud". Typing narrows the list that
/// is already open, and clearing the box brings the whole list back.
///
/// Drawn as the app's own borderless cream field rather than the outlined box
/// it used to be — it sits at the top of a column of `AppTextField`s and
/// `AppDropdownField`s, and an `OutlineInputBorder` there was the one grey
/// rectangle on the form. Choosing a customer collapses the list and shows
/// them as a cream card, so the chosen name survives scrolling away.
class CustomerPickerField extends ConsumerStatefulWidget {
  const CustomerPickerField({super.key, required this.chosen, required this.onChosen});

  final CustomerOption? chosen;
  final ValueChanged<CustomerOption> onChosen;

  @override
  ConsumerState<CustomerPickerField> createState() => _CustomerPickerFieldState();
}

class _CustomerPickerFieldState extends ConsumerState<CustomerPickerField> {
  final _controller = TextEditingController();

  /// Whether the list is hanging under the field. Local to the widget, not in
  /// the controller: the provider is shared, and one screen's open list must
  /// not decide another's.
  bool _open = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openList() {
    final notifier = ref.read(customerPickerControllerProvider.notifier);
    final query = _controller.text.trim();

    setState(() => _open = true);

    if (query.isEmpty) {
      notifier.loadAll();
    } else {
      notifier.search(query);
    }
  }

  void _closeList() {
    setState(() => _open = false);
    ref.read(customerPickerControllerProvider.notifier).dismiss();
    FocusScope.of(context).unfocus();
  }

  void _choose(CustomerOption customer) {
    widget.onChosen(customer);

    // The name is shown on the card below, so leaving the query in the box and
    // the list open would say the same thing three times.
    _controller.clear();
    _closeList();
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
            onTap: _openList,
            // Typing opens it too: a hardware keyboard, or text restored into
            // the field, never fires `onTap`, and a list that stayed shut
            // while results arrived would read as a picker finding nobody.
            onChanged: (value) {
              if (!_open) {
                setState(() => _open = true);
              }

              ref.read(customerPickerControllerProvider.notifier).search(value);
            },
            decoration: InputDecoration(
              labelText: 'Customer',
              labelStyle: const TextStyle(color: Colors.grey),
              hintText: 'Tap to see all, or type a name or mobile',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13.5),
              prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
              // The arrow is what says "dropdown" — a search icon on its own
              // read as a box you had to type into.
              suffixIcon: IconButton(
                icon: Icon(_open ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: Colors.grey),
                tooltip: _open ? 'Hide the list' : 'Show all customers',
                onPressed: _open ? _closeList : _openList,
              ),
              border: InputBorder.none,
              filled: true,
              fillColor: fill.withValues(alpha: isDark ? 1 : 0.6),
            ),
          ),
        ),
        if (_open && state.loading)
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
        if (_open && state.error == null) _panel(state, fill),
        if (chosen != null && !_open) _chosenCard(chosen, fill),
      ],
    );
  }

  Widget _panel(CustomerPickerState state, Color fill) {
    if (state.options.isEmpty) {
      return state.loading ? const SizedBox.shrink() : _note('No customers match that.', fill);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _results(state.options, fill),
        // A browse is one page, not the whole book: saying so costs a line,
        // and typing is the answer either way.
        if (state.hasMore)
          _note('Showing the first ${state.options.length} — type to narrow.', fill),
      ],
    );
  }

  /// Capped and scrollable: the whole customer book opens here, and an
  /// uncapped list would push the rest of the form off the screen.
  Widget _results(List<CustomerOption> options, Color fill) => Container(
        margin: const EdgeInsets.only(top: 6),
        constraints: const BoxConstraints(maxHeight: 260),
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
              final isChosen = widget.chosen?.id == customer.id;

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
                trailing:
                    isChosen ? const Icon(Icons.check_circle, size: 18, color: Colors.green) : null,
                onTap: () => _choose(customer),
              );
            },
          ),
        ),
      );

  Widget _note(String text, Color fill) => Container(
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: fill.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(text, style: const TextStyle(fontSize: 12, color: appTextColorSecondary)),
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
