import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/app_dropdown_field.dart';
import '../../../../shared/widgets/app_picker_field.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/form_note.dart';
import '../../../../shared/widgets/form_section_heading.dart';
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

  static final _dateFormat = DateFormat('EEE, d MMM yyyy');

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

    // No amount in the message: a booking has no price until an admin picks
    // the tanker that will deliver it, and "₹ 0" read as "free".
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order ${order.orderNo} placed. We will assign a tanker shortly.'),
      ),
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _BookingHeader(),

            const FormSectionHeading('How much water'),
            TankerCountField(
              value: _tankers,
              onChanged: (count) => setState(() => _tankers = count),
            ),
            const SizedBox(height: 6),
            const FormNote(
              'Water is sold by the tanker-load. What it comes to is confirmed once '
              'the office assigns a tanker — you will see it on the order.',
            ),

            const FormSectionHeading('Where and when'),
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
            const SizedBox(height: 12),
            AppPickerField(
              label: 'Delivery date',
              hint: 'Choose a date',
              value: _dateFormat.format(_date),
              icon: Icons.event_outlined,
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),
            slots.when(
              data: (options) => AppDropdownField<int>(
                label: 'Delivery slot',
                value: _slotId,
                icon: Icons.schedule_outlined,
                items: [
                  const DropdownMenuItem(value: null, child: Text('Any time that day')),
                  ...options.map(
                    (slot) => DropdownMenuItem(value: slot.id, child: Text(slot.label)),
                  ),
                ],
                onChanged: (value) => setState(() => _slotId = value),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const FormNote('Could not load delivery slots.'),
            ),

            const FormSectionHeading('Anything else'),
            AppTextField(
              controller: _notes,
              label: 'Notes',
              hint: 'Gate code, landmark, who to ring',
              maxLines: 2,
            ),
            if (formState.failure != null) ...[
              const SizedBox(height: 16),
              Text(
                formState.failure!.message,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Place Order',
              busy: formState.submitting,
              icon: Icons.local_shipping_outlined,
              onPressed: _submit,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}


/// A line at the top of the booking form saying what will happen, because the
/// first question a customer has is "and then what?" — the order does not go
/// straight to a driver, the office assigns one, and the price follows that
/// tanker.
class _BookingHeader extends StatelessWidget {
  const _BookingHeader();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : appetitAppContainerColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(color: appColorPrimary, shape: BoxShape.circle),
            child: const Icon(Icons.water_drop, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Book a tanker',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 3),
                Text(
                  'Tell us how many loads and when. The office assigns a tanker and '
                  'you can follow it from My Orders.',
                  style: TextStyle(fontSize: 12, height: 1.35, color: appTextColorSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
