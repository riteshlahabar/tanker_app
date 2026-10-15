import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../domain/customer_option.dart';
import '../providers/admin_orders_controller.dart';
import '../providers/new_order_controller.dart';
import '../widgets/new_order_customer_picker.dart';
import 'admin_order_detail_screen.dart';

/// "New Order" tab — an admin typing in a phone order for a customer. Unlike
/// the customer's own form, the amount is typed by hand here (`CLAUDE.md`:
/// "Admin-entered orders remain typed by hand").
class NewOrderScreen extends ConsumerStatefulWidget {
  const NewOrderScreen({super.key});

  @override
  ConsumerState<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends ConsumerState<NewOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _address = TextEditingController();
  final _litres = TextEditingController();
  final _amount = TextEditingController();
  final _notes = TextEditingController();
  DateTime _date = DateTime.now();
  int? _slotId;
  CustomerOption? _customer;

  @override
  void dispose() {
    _address.dispose();
    _litres.dispose();
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _onCustomerChosen(CustomerOption customer) {
    setState(() {
      _customer = customer;
      _address.text = customer.address ?? '';
    });
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
    if (_customer == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Choose a customer first.')));

      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref.read(newOrderControllerProvider.notifier).submit(
          customerId: _customer!.id,
          deliveryAddress: _address.text.trim(),
          deliveryDate: _date,
          orderAmount: double.tryParse(_amount.text.trim()) ?? 0,
          latitude: _customer!.latitude,
          longitude: _customer!.longitude,
          deliverySlotId: _slotId,
          quantityLitres: int.tryParse(_litres.text.trim()),
          notes: _notes.text.trim(),
        );

    if (!mounted) return;

    final order = ref.read(newOrderControllerProvider).placedOrder;

    if (order == null) return;

    ref.invalidate(adminOrdersControllerProvider);
    ref.read(newOrderControllerProvider.notifier).reset();

    setState(() {
      _customer = null;
      _address.clear();
      _litres.clear();
      _amount.clear();
      _notes.clear();
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Order ${order.orderNo} placed.')));

    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => AdminOrderDetailScreen(orderId: order.id)));
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(newOrderControllerProvider);
    final slots = ref.watch(deliverySlotOptionsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NewOrderCustomerPicker(chosen: _customer, onChosen: _onCustomerChosen),
            const SizedBox(height: 16),
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
                decoration:
                    const InputDecoration(labelText: 'Delivery date', border: OutlineInputBorder()),
                child: Text('${_date.day}/${_date.month}/${_date.year}'),
              ),
            ),
            const SizedBox(height: 16),
            slots.when(
              data: (options) => DropdownButtonFormField<int>(
                initialValue: _slotId,
                decoration:
                    const InputDecoration(labelText: 'Delivery slot', border: OutlineInputBorder()),
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
              hint: 'Optional',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _amount,
              label: 'Amount (₹)',
              hint: 'Typed by hand for a phone order',
              keyboardType: TextInputType.number,
              validator: (value) {
                final amount = double.tryParse(value?.trim() ?? '');

                return (amount == null || amount < 0) ? 'Enter a valid amount' : null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(controller: _notes, label: 'Notes', hint: 'Optional', maxLines: 2),
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
