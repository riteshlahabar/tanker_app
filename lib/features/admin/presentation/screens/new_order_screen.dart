import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/models/spot.dart';
import '../../../../shared/widgets/app_dropdown_field.dart';
import '../../../../shared/widgets/app_picker_field.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/form_note.dart';
import '../../../../shared/widgets/form_section_heading.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/tanker_count_field.dart';
import '../../../driver/presentation/providers/driver_providers.dart' as driver;
import '../../domain/customer_option.dart';
import '../../domain/driver_option.dart';
import '../providers/admin_orders_controller.dart';
import '../providers/new_order_controller.dart';
import '../widgets/driver_picker_sheet.dart';
import '../widgets/new_order_customer_picker.dart';
import 'admin_order_detail_screen.dart';

/// "New Order" tab — an admin writing down a phone order.
///
/// The questions are asked in the order the price becomes knowable, which is
/// also the order the panel's form asks them in: who it is for, when and where
/// it goes, **which driver** — and only then a rate, because the rate is the
/// one on the tanker that driver holds. There is no amount field: the total is
/// `rate × tankers`, shown live, and the only thing the admin can override is
/// the rate.
class NewOrderScreen extends ConsumerStatefulWidget {
  const NewOrderScreen({super.key});

  @override
  ConsumerState<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends ConsumerState<NewOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _address = TextEditingController();
  final _rate = TextEditingController();
  final _notes = TextEditingController();

  int _tankers = 1;
  DateTime _date = DateTime.now();
  int? _slotId;
  int? _spotId;
  CustomerOption? _customer;
  DriverOption? _driver;
  List<Spot> _spots = const [];

  /// The rate follows the chosen driver's tanker until the admin types over
  /// it. After that their figure stands — re-filling it on the next driver
  /// change would quietly discard what they entered.
  bool _rateIsTheirs = false;

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
    final ApiResult<List<Spot>> result = await ref.read(driver.spotRepositoryProvider).usable();

    if (!mounted) return;

    setState(() => _spots = result.valueOrNull ?? const []);
  }

  double get _rateValue => double.tryParse(_rate.text.trim()) ?? 0;

  double get _total => _rateValue * _tankers;

  void _onCustomerChosen(CustomerOption customer) {
    setState(() {
      _customer = customer;
      _address.text = customer.address ?? '';
    });
  }

  Future<void> _pickDriver() async {
    final chosen = await showModalBottomSheet<DriverOption>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const DriverPickerSheet(title: 'Who is delivering?'),
    );

    if (chosen == null) return;

    setState(() {
      _driver = chosen;

      final rate = chosen.tankerRate ?? 0;

      if (!_rateIsTheirs && rate > 0) _rate.text = rate.toStringAsFixed(2);
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
      _say('Choose a customer first.');

      return;
    }

    if (_driver == null) {
      _say('Choose a driver — the price comes from their tanker.');

      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Only a rate the admin changed is sent: left at the vehicle's own it is
    // not an override, and the server stays free to re-price the order from
    // whichever tanker actually goes out.
    final vehicleRate = _driver!.tankerRate ?? 0;
    final typed = _rateValue;
    final override = (typed - vehicleRate).abs() < 0.01 ? null : typed;

    await ref.read(newOrderControllerProvider.notifier).submit(
          customerId: _customer!.id,
          driverId: _driver!.id,
          deliveryAddress: _address.text.trim(),
          deliveryDate: _date,
          spotId: _spotId,
          tankerRate: override,
          deliverySlotId: _slotId,
          tankerCount: _tankers,
          notes: _notes.text.trim(),
        );

    if (!mounted) return;

    final order = ref.read(newOrderControllerProvider).placedOrder;

    if (order == null) return;

    ref.invalidate(adminOrdersControllerProvider);
    ref.read(newOrderControllerProvider.notifier).reset();

    setState(() {
      _customer = null;
      _driver = null;
      _address.clear();
      _rate.clear();
      _notes.clear();
      _tankers = 1;
      _spotId = null;
      _rateIsTheirs = false;
    });

    _say('Order ${order.orderNo} placed and assigned.');

    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => AdminOrderDetailScreen(orderId: order.id)));
  }

  void _say(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(newOrderControllerProvider);
    final slots = ref.watch(deliverySlotOptionsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FormSectionHeading('Customer'),
            NewOrderCustomerPicker(chosen: _customer, onChosen: _onCustomerChosen),

            const FormSectionHeading('Delivery'),
            AppPickerField(
              label: 'Delivery date',
              hint: 'Choose a date',
              value: _dateFormat.format(_date),
              icon: Icons.event_outlined,
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _address,
              label: 'Delivery address',
              hint: 'Where should the tanker deliver?',
              maxLines: 3,
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Enter a delivery address' : null,
            ),
            const SizedBox(height: 12),
            slots.when(
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
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const FormNote('Could not load delivery slots.'),
            ),

            const FormSectionHeading('Driver and price'),
            AppPickerField(
              label: 'Driver',
              hint: 'Choose who delivers',
              value: _driver == null
                  ? null
                  : '${_driver!.fullName} · ${_driver!.tankerLabel ?? 'no tanker'}',
              icon: Icons.local_shipping_outlined,
              onTap: _pickDriver,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _rate,
              label: 'Rate per tanker (₹)',
              hint: _driver == null ? 'Choose a driver first' : 'From their tanker',
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() => _rateIsTheirs = true),
              validator: (value) {
                final rate = double.tryParse(value?.trim() ?? '');

                return (rate == null || rate < 0) ? 'Enter a rate per tanker' : null;
              },
            ),
            const SizedBox(height: 6),
            FormNote(
              _driver == null
                  ? 'Picking a driver fills this in from the tanker they hold.'
                  : (_driver!.tankerRate ?? 0) > 0
                      ? 'Filled from ${_driver!.tankerLabel}. Change it only to sell this load at a different price.'
                      : 'This driver\'s tanker has no rate set — enter one, or the order saves at ₹ 0.',
            ),
            const SizedBox(height: 12),
            TankerCountField(
              value: _tankers,
              onChanged: (count) => setState(() => _tankers = count),
            ),
            const SizedBox(height: 12),
            _TotalCard(rate: _rateValue, tankers: _tankers, total: _total),

            const FormSectionHeading('Filling point'),
            AppDropdownField<int>(
              label: 'Filling point',
              value: _spotId,
              icon: Icons.water_drop_outlined,
              items: [
                const DropdownMenuItem(value: null, child: Text('Decide on the route')),
                ..._spots.map(
                  (spot) => DropdownMenuItem(
                    value: spot.id,
                    child: Text('${spot.name} · ₹ ${spot.refillCharge.toStringAsFixed(0)}'),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _spotId = value),
            ),
            const SizedBox(height: 6),
            const FormNote('Where this load is filled. Its refill charge is saved onto the order.'),

            const FormSectionHeading('Notes'),
            AppTextField(controller: _notes, label: 'Notes', hint: 'Optional', maxLines: 2),

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
              icon: Icons.check_circle_outline,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

/// The total, shown as a result rather than a field — it is not something the
/// admin can type any more, it is what the two numbers above come to.
class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.rate, required this.tankers, required this.total});

  final double rate;
  final int tankers;
  final double total;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : appetitAppContainerColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL AMOUNT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: appTextColorSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$tankers × ₹ ${rate.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12, color: appTextColorSecondary),
                ),
              ],
            ),
          ),
          Text(
            '₹ ${total.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : appColorPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
