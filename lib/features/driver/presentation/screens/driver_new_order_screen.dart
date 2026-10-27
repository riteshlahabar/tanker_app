import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/models/customer_option.dart';
import '../../../../shared/models/spot.dart';
import '../../../../shared/models/tanker_info.dart';
import '../../../../shared/widgets/app_dropdown_field.dart';
import '../../../../shared/widgets/app_picker_field.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/customer_picker_field.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/form_note.dart';
import '../../../../shared/widgets/form_section_heading.dart';
import '../../../../shared/widgets/order_total_card.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/tanker_count_field.dart';
import '../providers/driver_new_order_controller.dart';
import '../providers/driver_orders_controller.dart';
import '../providers/driver_providers.dart';
import '../providers/driver_summary_controller.dart';
import 'driver_order_detail_screen.dart';

/// A driver writing down a job they have just been given on the route.
///
/// The admin's New Order form **minus the driver picker**: this order can only
/// ever go to the driver filling it in, so there is no question to ask. That
/// is enforced on the server — `DriverPlaceOrderRequest` reads the driver from
/// the token and has no `driver_id` rule at all — so the screen is not the
/// thing keeping it honest, it just has nothing to show.
///
/// Everything else mirrors the admin's: customer, when and where, the rate
/// (pre-filled from their own tanker and editable, because the owner's drivers
/// do negotiate), the count, the filling point if they already know it.
///
/// No `Scaffold` — it is a shell tab body, and the shell draws the app bar and
/// the bottom bar.
class DriverNewOrderScreen extends ConsumerStatefulWidget {
  const DriverNewOrderScreen({super.key});

  @override
  ConsumerState<DriverNewOrderScreen> createState() => _DriverNewOrderScreenState();
}

class _DriverNewOrderScreenState extends ConsumerState<DriverNewOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _address = TextEditingController();
  final _rate = TextEditingController();
  final _notes = TextEditingController();

  int _tankers = 1;
  DateTime _date = DateTime.now();
  int? _slotId;
  int? _spotId;
  CustomerOption? _customer;
  List<Spot> _spots = const [];

  /// True once the driver has typed in the rate field, so re-reading their
  /// tanker never overwrites a figure they chose. Same latch the admin's form
  /// uses.
  bool _rateIsTheirs = false;

  /// The vehicle rate the field was pre-filled from, kept so submit can tell
  /// "left alone" from "typed back to the same number" — only a real override
  /// should set `rate_fixed` server-side.
  double _vehicleRate = 0;

  static final _dateFormat = DateFormat('EEE, d MMM yyyy');

  @override
  void initState() {
    super.initState();
    _loadSpots();
  }

  @override
  void dispose() {
    _address.dispose();
    _rate.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _loadSpots() async {
    final ApiResult<List<Spot>> result = await ref.read(spotRepositoryProvider).usable();

    if (!mounted) return;

    setState(() => _spots = result.valueOrNull ?? const []);
  }

  double get _rateValue => double.tryParse(_rate.text.trim()) ?? 0;

  double get _total => _rateValue * _tankers;

  /// Fills the rate from the driver's own tanker, once, unless they have
  /// already typed one.
  void _syncRate(TankerInfo tanker) {
    _vehicleRate = tanker.rate;

    if (_rateIsTheirs || _vehicleRate <= 0 || _rate.text.isNotEmpty) return;

    _rate.text = _vehicleRate.toStringAsFixed(2);
  }

  void _onCustomerChosen(CustomerOption customer) {
    setState(() {
      _customer = customer;
      // The server would default this from the customer's record anyway; doing
      // it here lets the driver see and correct it before sending.
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
    final customer = _customer;

    if (customer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a customer first.')),
      );

      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final typed = _rateValue;
    // Equal to the vehicle's rate is not an override — the field was
    // pre-filled with it, so the commonest submit would otherwise latch
    // `rate_fixed` and stop the office re-pricing a handover.
    final override = (typed - _vehicleRate).abs() < 0.01 ? null : typed;

    await ref.read(driverNewOrderControllerProvider.notifier).submit(
          customerId: customer.id,
          deliveryAddress: _address.text.trim(),
          deliveryDate: _date,
          deliverySlotId: _slotId,
          spotId: _spotId,
          tankerCount: _tankers,
          tankerRate: override,
          notes: _notes.text.trim(),
        );

    if (!mounted) return;

    final placed = ref.read(driverNewOrderControllerProvider).placedOrder;

    if (placed == null) return;

    // Both: the new order is theirs and today's counts moved with it.
    ref.invalidate(driverOrdersControllerProvider(true));
    ref.invalidate(driverOrdersControllerProvider(false));
    // Not awaited: today's counts catching up is not worth holding the
    // success snackbar for.
    unawaited(ref.read(driverSummaryControllerProvider.notifier).refresh());
    ref.read(driverNewOrderControllerProvider.notifier).reset();

    setState(() {
      _customer = null;
      _address.clear();
      _notes.clear();
      _rate.clear();
      _rateIsTheirs = false;
      _tankers = 1;
      _date = DateTime.now();
      _slotId = null;
      _spotId = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order ${placed.orderNo} placed. It is yours to deliver.')),
    );

    // Push, not pushReplacement: this screen is inside the shell, and
    // replacing it would take the bottom bar with it.
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => DriverOrderDetailScreen(orderId: placed.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(driverSummaryControllerProvider);
    final tanker = summary.summary?.tanker;

    if (summary.loading && summary.summary == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Refused before the form rather than at submit: an order is priced from
    // the vehicle that delivers it, and assignment refuses a driver holding
    // none — so a form here could only ever end in a 400.
    if (tanker == null) {
      return const EmptyState(
        icon: Icons.local_shipping_outlined,
        title: 'No tanker assigned to you',
        message: 'The office has to put you on a tanker before you can take an order — '
            'the price of a delivery comes from the vehicle that carries it.',
      );
    }

    _syncRate(tanker);

    final formState = ref.watch(driverNewOrderControllerProvider);
    final slots = ref.watch(deliverySlotOptionsProvider);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          const FormSectionHeading('Customer'),
          CustomerPickerField(chosen: _customer, onChosen: _onCustomerChosen),
          const SizedBox(height: 16),
          const FormSectionHeading('Delivery'),
          AppPickerField(
            label: 'Delivery date',
            hint: 'Pick a day',
            value: _dateFormat.format(_date),
            icon: Icons.calendar_today_outlined,
            onTap: _pickDate,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _address,
            label: 'Delivery address',
            hint: 'Where the water is going',
            maxLines: 3,
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'Enter the delivery address' : null,
          ),
          const SizedBox(height: 12),
          slots.when(
            loading: () => const LinearProgressIndicator(minHeight: 2),
            error: (_, _) => const FormNote('Delivery windows could not be loaded.'),
            data: (options) => AppDropdownField<int>(
              label: 'Delivery slot',
              value: _slotId,
              icon: Icons.schedule_outlined,
              items: [
                const DropdownMenuItem(value: null, child: Text('No particular window')),
                ...options.map(
                  (slot) => DropdownMenuItem(value: slot.id, child: Text(slot.label)),
                ),
              ],
              onChanged: (value) => setState(() => _slotId = value),
            ),
          ),
          const SizedBox(height: 16),
          const FormSectionHeading('Your tanker and the price'),
          _TankerLine(tanker: tanker),
          const SizedBox(height: 12),
          AppTextField(
            controller: _rate,
            label: 'Rate per tanker (₹)',
            hint: 'What one load sells for',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() => _rateIsTheirs = true),
            validator: (value) {
              final rate = double.tryParse((value ?? '').trim());

              if (rate == null || rate < 0) return 'Enter the rate for one tanker';

              return null;
            },
          ),
          const SizedBox(height: 6),
          FormNote(
            _vehicleRate > 0
                ? 'Filled in from ${tanker.vehicleNumber}. Change it only if this load '
                    'was agreed at a different price.'
                : 'Your tanker has no rate set, so the order saves unpriced unless you '
                    'type one here.',
          ),
          const SizedBox(height: 12),
          TankerCountField(
            value: _tankers,
            onChanged: (value) => setState(() => _tankers = value),
          ),
          const SizedBox(height: 12),
          OrderTotalCard(rate: _rateValue, tankers: _tankers, total: _total),
          const SizedBox(height: 16),
          const FormSectionHeading('Filling point'),
          AppDropdownField<int>(
            label: 'Filling point',
            value: _spotId,
            icon: Icons.local_drink_outlined,
            items: [
              const DropdownMenuItem(value: null, child: Text('Decide on the route')),
              ..._spots.map((spot) => DropdownMenuItem(value: spot.id, child: Text(spot.name))),
            ],
            onChanged: (value) => setState(() => _spotId = value),
          ),
          const SizedBox(height: 6),
          const FormNote(
            'Leave it out and you will be asked when you start the refill.',
          ),
          const SizedBox(height: 16),
          const FormSectionHeading('Notes'),
          AppTextField(
            controller: _notes,
            label: 'Notes (optional)',
            hint: 'Anything the office should know',
            maxLines: 2,
          ),
          if (formState.failure != null) ...[
            const SizedBox(height: 12),
            Text(
              formState.failure!.message,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Place Order',
            icon: Icons.check_circle_outline,
            busy: formState.submitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

/// Which vehicle this order will be priced from and delivered on. Read-only:
/// a driver has exactly one current tanker, so this is information, not a
/// choice.
class _TankerLine extends StatelessWidget {
  const _TankerLine({required this.tanker});

  final TankerInfo tanker;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : appetitAppContainerColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping_outlined, size: 20, color: appetitBrownColor),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tanker.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  tanker.rate > 0
                      ? '₹ ${tanker.rate.toStringAsFixed(0)} per tanker'
                      : 'No rate set on this tanker',
                  style: const TextStyle(fontSize: 12, color: appTextColorSecondary),
                ),
              ],
            ),
          ),
          const Text(
            'You are delivering',
            style: TextStyle(fontSize: 11, color: appTextColorSecondary),
          ),
        ],
      ),
    );
  }
}
