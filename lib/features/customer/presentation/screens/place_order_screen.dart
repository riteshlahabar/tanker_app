import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/presentation/providers/session_controller.dart';
import '../../../auth/presentation/providers/session_state.dart';
import '../providers/my_orders_controller.dart';
import '../providers/place_order_controller.dart';
import 'order_detail_screen.dart';

/// The Order tab's body. A standing-order customer (`canSelfOrder == false`)
/// sees the same refusal wording the backend would give a submit, instead of
/// a form that could only ever fail.
class PlaceOrderScreen extends ConsumerStatefulWidget {
  const PlaceOrderScreen({super.key});

  @override
  ConsumerState<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends ConsumerState<PlaceOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _address;
  final _notes = TextEditingController();
  final _litres = TextEditingController();
  DateTime _date = DateTime.now();
  int? _slotId;
  bool _addressPrefilled = false;

  @override
  void initState() {
    super.initState();
    _address = TextEditingController();
  }

  @override
  void dispose() {
    _address.dispose();
    _notes.dispose();
    _litres.dispose();
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
          quantityLitres: int.tryParse(_litres.text.trim()),
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

    await Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: order.id)));
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    final user = session is SessionSignedIn ? session.user : null;

    if (user != null && !_addressPrefilled) {
      _address.text = user.address ?? '';
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
              hint: 'Where should the tanker deliver?',
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
            AppTextField(
              controller: _litres,
              label: 'Quantity (litres)',
              hint: 'Optional — leave blank for the usual amount',
              keyboardType: TextInputType.number,
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
