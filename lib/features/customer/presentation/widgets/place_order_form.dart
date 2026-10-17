import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/tanker_count_field.dart';
import '../../../auth/presentation/providers/session_controller.dart';
import '../../../auth/presentation/providers/session_state.dart';
import '../providers/my_orders_controller.dart';
import '../providers/place_order_controller.dart';
import '../screens/order_detail_screen.dart';

/// The booking form itself, with no Scaffold of its own, so it can be the
/// Order tab's body *and* the body of the pushed "Book a Tanker" screen.
///
/// A standing-order customer (`canSelfOrder == false`) sees the same refusal
/// wording the backend would give a submit, instead of a form that could only
/// ever fail.
class PlaceOrderForm extends ConsumerStatefulWidget {
  const PlaceOrderForm({super.key, this.replaceSelfOnPlaced = false});

  /// Where the order detail screen should go once an order is placed.
  ///
  /// `true` for the pushed Book-a-Tanker route: the detail *replaces* the
  /// form, so Back returns to Home rather than to a form that has been
  /// submitted. `false` for the Order tab, where the form is inside the shell
  /// — replacing it there would replace the shell, which is the only root
  /// route, and take the bottom bar down with it.
  final bool replaceSelfOnPlaced;

  @override
  ConsumerState<PlaceOrderForm> createState() => _PlaceOrderFormState();
}

class _PlaceOrderFormState extends ConsumerState<PlaceOrderForm> {
  final _formKey = GlobalKey<FormState>();
  final _address = TextEditingController();
  final _notes = TextEditingController();
  int _tankers = 1;
  DateTime _date = DateTime.now();
  int? _slotId;
  bool _addressPrefilled = false;

  @override
  void initState() {
    super.initState();

    // The delivery address defaults to the one the admin entered for this
    // customer, so it is worth re-reading: an address added to their record
    // after they signed in would otherwise not show until the next launch.
    // Deferred, because touching a provider while the tree is building throws.
    Future<void>.microtask(
      () => ref.read(sessionControllerProvider.notifier).refreshUser(),
    );
  }

  @override
  void dispose() {
    _address.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref.read(placeOrderControllerProvider.notifier).submit(
          deliveryAddress: _address.text.trim(),
          deliveryDate: _date,
          deliverySlotId: _slotId,
          tankerCount: _tankers,
          notes: _notes.text.trim(),
        );

    if (!mounted) return;

    final order = ref.read(placeOrderControllerProvider).placedOrder;

    if (order == null) return;

    ref.invalidate(myOrdersControllerProvider(true));
    ref.read(placeOrderControllerProvider.notifier).reset();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order ${order.orderNo} placed — ₹ ${order.orderAmount.toStringAsFixed(0)}')),
    );

    final detail = MaterialPageRoute<void>(builder: (_) => OrderDetailScreen(orderId: order.id));

    await (widget.replaceSelfOnPlaced
        ? Navigator.of(context).pushReplacement(detail)
        : Navigator.of(context).push(detail));
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    final user = session is SessionSignedIn ? session.user : null;

    // Filled from the customer's own record — the address given when the
    // admin added them. The flag is only raised once something was actually
    // written, so an address that arrives with the refresh above still lands,
    // while an address the customer has since edited is never overwritten.
    if (!_addressPrefilled && (user?.address ?? '').isNotEmpty) {
      _address.text = user!.address!;
      _addressPrefilled = true;
    }

    if (user != null && !user.canSelfOrder) {
      return const EmptyState(
        icon: Icons.event_repeat,
        title: 'Your deliveries are on a routine',
        message: 'Your deliveries are on a fixed routine managed by the office. '
            'Please ring them to change an order — see your next delivery on the Home tab.',
      );
    }

    final formState = ref.watch(placeOrderControllerProvider);
    final slots = ref.watch(deliverySlotOptionsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: _address,
              label: 'Delivery address',
              hint: _addressPrefilled
                  ? 'Your saved address — change it for a one-off delivery'
                  : 'Where should the tanker deliver?',
              maxLines: 3,
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Enter a delivery address' : null,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Delivery date', border: OutlineInputBorder()),
                child: Text('${_date.day}/${_date.month}/${_date.year}'),
              ),
            ),
            const SizedBox(height: 16),
            slots.when(
              data: (options) => DropdownButtonFormField<int>(
                initialValue: _slotId,
                decoration: const InputDecoration(labelText: 'Delivery slot', border: OutlineInputBorder()),
                items: options
                    .map((slot) => DropdownMenuItem(value: slot.id, child: Text(slot.label)))
                    .toList(),
                onChanged: (value) => setState(() => _slotId = value),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const Text('Could not load delivery slots.'),
            ),
            const SizedBox(height: 16),
            TankerCountField(
              value: _tankers,
              onChanged: (count) => setState(() => _tankers = count),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _notes,
              label: 'Notes',
              hint: 'Optional',
              maxLines: 2,
            ),
            if (formState.failure != null) ...[
              const SizedBox(height: 16),
              Text(formState.failure!.message, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            PrimaryButton(label: 'Place Order', busy: formState.submitting, onPressed: _submit),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
