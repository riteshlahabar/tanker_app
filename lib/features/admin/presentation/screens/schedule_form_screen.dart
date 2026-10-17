import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/shell_tab_bar.dart';
import '../../../../shared/widgets/tanker_count_field.dart';
import '../../domain/admin_schedule.dart';
import '../../domain/customer_option.dart';
import '../../domain/driver_option.dart';
import '../providers/admin_picker_controllers.dart';
import '../providers/admin_providers.dart';
import '../providers/admin_schedule_form_controller.dart';
import '../providers/admin_schedules_controller.dart';

/// Create (no [existing]) or edit a standing order. The customer is fixed
/// once created — `UpdateDeliveryScheduleRequest` refuses changing it, since
/// that would orphan the orders already generated.
class ScheduleFormScreen extends ConsumerStatefulWidget {
  const ScheduleFormScreen({super.key, this.existing});

  final AdminSchedule? existing;

  @override
  ConsumerState<ScheduleFormScreen> createState() => _ScheduleFormScreenState();
}

enum _Pattern { interval, weekdays }

enum _DeliveryTiming { slot, time }

class _ScheduleFormScreenState extends ConsumerState<ScheduleFormScreen> {
  final _formKey = GlobalKey<FormState>();

  CustomerOption? _customer;
  DriverOption? _preferredDriver;

  late _Pattern _patternMode =
      (widget.existing?.weekdays?.isNotEmpty ?? false) ? _Pattern.weekdays : _Pattern.interval;
  late final _intervalDays =
      TextEditingController(text: widget.existing?.intervalDays.toString() ?? '1');
  late final Set<int> _weekdays = (widget.existing?.weekdays ?? const []).toSet();

  late _DeliveryTiming _timingMode =
      widget.existing?.deliveryTime != null ? _DeliveryTiming.time : _DeliveryTiming.slot;
  int? _slotId;
  TimeOfDay? _deliveryTime;

  late int _tankers = widget.existing?.tankerCount ?? 1;
  late final _orderAmount =
      TextEditingController(text: widget.existing?.orderAmount?.toString() ?? '');
  late final _address = TextEditingController(text: widget.existing?.deliveryAddress);
  late final _latitude =
      TextEditingController(text: widget.existing?.latitude?.toString() ?? '');
  late final _longitude =
      TextEditingController(text: widget.existing?.longitude?.toString() ?? '');
  late final _notes = TextEditingController(text: widget.existing?.notes);
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  late bool _status = widget.existing?.status ?? true;

  static final _dateFormat = DateFormat('d MMM yyyy');
  static const _weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _slotId = widget.existing?.deliverySlotId;
    _deliveryTime = _parseTime(widget.existing?.deliveryTime);
    _startDate = widget.existing?.startDate ?? DateTime.now();
    _endDate = widget.existing?.endDate;
  }

  TimeOfDay? _parseTime(String? value) {
    if (value == null) return null;

    final parts = value.split(':');

    if (parts.length < 2) return null;

    return TimeOfDay(hour: int.tryParse(parts[0]) ?? 0, minute: int.tryParse(parts[1]) ?? 0);
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _intervalDays.dispose();
    _orderAmount.dispose();
    _address.dispose();
    _latitude.dispose();
    _longitude.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDriver() async {
    final chosen = await showModalBottomSheet<DriverOption>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _DriverPickerSheet(),
    );

    if (chosen != null) setState(() => _preferredDriver = chosen);
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );

    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _pickDeliveryTime() async {
    final picked = await showTimePicker(context: context, initialTime: _deliveryTime ?? TimeOfDay.now());

    if (picked != null) setState(() => _deliveryTime = picked);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final isEditing = widget.existing != null;

    if (!isEditing && _customer == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Choose a customer first.')));

      return;
    }

    if (_patternMode == _Pattern.weekdays && _weekdays.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Choose at least one weekday.')));

      return;
    }

    if (_timingMode == _DeliveryTiming.slot && _slotId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Choose a delivery slot.')));

      return;
    }

    if (_timingMode == _DeliveryTiming.time && _deliveryTime == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Choose a delivery time.')));

      return;
    }

    final endDate = _endDate == null ? null : DateFormat('yyyy-MM-dd').format(_endDate!);

    await ref.read(adminScheduleFormControllerProvider.notifier).submit(
          {
            if (!isEditing) 'customer_id': _customer!.id,
            'interval_days': int.tryParse(_intervalDays.text.trim()) ?? 1,
            'weekdays': _patternMode == _Pattern.weekdays ? _weekdays.toList() : null,
            'tanker_count': _tankers,
            'order_amount': ?double.tryParse(_orderAmount.text.trim()),
            'delivery_slot_id': _timingMode == _DeliveryTiming.slot ? _slotId : null,
            'delivery_time':
                _timingMode == _DeliveryTiming.time ? _formatTime(_deliveryTime!) : null,
            'delivery_address': _address.text.trim().isEmpty ? null : _address.text.trim(),
            'latitude': ?double.tryParse(_latitude.text.trim()),
            'longitude': ?double.tryParse(_longitude.text.trim()),
            'preferred_driver_id': ?(_preferredDriver?.id ?? widget.existing?.preferredDriverId),
            'start_date': DateFormat('yyyy-MM-dd').format(_startDate),
            'end_date': endDate,
            'notes': _notes.text.trim().isEmpty ? null : _notes.text.trim(),
            'status': _status,
          },
          id: widget.existing?.id,
        );

    if (!mounted) return;

    final saved = ref.read(adminScheduleFormControllerProvider).saved;

    if (saved == null) return;

    ref.invalidate(adminSchedulesControllerProvider);
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove this standing order?'),
        content: const Text('Orders already generated are kept.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove')),
        ],
      ),
    );

    if (confirmed != true) return;

    final result =
        await ref.read(adminScheduleRepositoryProvider).delete(widget.existing!.id);

    if (!mounted) return;

    result.when(
      success: (_) {
        ref.invalidate(adminSchedulesControllerProvider);
        Navigator.of(context)
          ..pop()
          ..pop();
      },
      error: (failure) =>
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(adminScheduleFormControllerProvider);
    final isEditing = widget.existing != null;
    final slots = ref.watch(deliverySlotOptionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Standing Order' : 'Add Standing Order'),
        actions: [
          if (isEditing) IconButton(icon: const Icon(Icons.delete_outline), onPressed: _delete),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isEditing)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Customer: ${widget.existing!.customerName ?? '#${widget.existing!.customerId}'}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                )
              else
                _CustomerPickerField(
                  chosen: _customer,
                  onChosen: (c) => setState(() => _customer = c),
                ),
              const SizedBox(height: 16),
              const Text('Pattern', style: TextStyle(fontWeight: FontWeight.w700)),
              SegmentedButton<_Pattern>(
                segments: const [
                  ButtonSegment(value: _Pattern.interval, label: Text('Every N days')),
                  ButtonSegment(value: _Pattern.weekdays, label: Text('Named weekdays')),
                ],
                selected: {_patternMode},
                onSelectionChanged: (s) => setState(() => _patternMode = s.first),
              ),
              const SizedBox(height: 12),
              if (_patternMode == _Pattern.interval)
                AppTextField(
                  controller: _intervalDays,
                  label: 'Interval (days)',
                  hint: '1 = daily, 2 = alternate day',
                  keyboardType: TextInputType.number,
                )
              else
                Wrap(
                  spacing: 8,
                  children: [
                    for (var i = 0; i < 7; i++)
                      FilterChip(
                        label: Text(_weekdayLabels[i]),
                        selected: _weekdays.contains(i + 1),
                        onSelected: (selected) => setState(() {
                          if (selected) {
                            _weekdays.add(i + 1);
                          } else {
                            _weekdays.remove(i + 1);
                          }
                        }),
                      ),
                  ],
                ),
              const SizedBox(height: 20),
              const Text('Delivery timing', style: TextStyle(fontWeight: FontWeight.w700)),
              SegmentedButton<_DeliveryTiming>(
                segments: const [
                  ButtonSegment(value: _DeliveryTiming.slot, label: Text('Delivery window')),
                  ButtonSegment(value: _DeliveryTiming.time, label: Text('Exact time')),
                ],
                selected: {_timingMode},
                onSelectionChanged: (s) => setState(() => _timingMode = s.first),
              ),
              const SizedBox(height: 12),
              if (_timingMode == _DeliveryTiming.slot)
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
                )
              else
                InkWell(
                  onTap: _pickDeliveryTime,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Delivery time', border: OutlineInputBorder()),
                    child: Text(_deliveryTime == null ? 'Choose' : _deliveryTime!.format(context)),
                  ),
                ),
              const SizedBox(height: 20),
              TankerCountField(
                value: _tankers,
                label: 'Tankers per delivery',
                onChanged: (count) => setState(() => _tankers = count),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _orderAmount,
                label: 'Amount per delivery',
                hint: 'Optional — leave blank to price automatically',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              AppTextField(controller: _address, label: 'Delivery address', hint: 'Optional', maxLines: 3),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _latitude,
                      label: 'Latitude',
                      hint: 'Optional',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _longitude,
                      label: 'Longitude',
                      hint: 'Optional',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.local_shipping_outlined),
                title: Text(_preferredDriver?.fullName ??
                    widget.existing?.preferredDriver ??
                    'No preferred driver'),
                trailing: TextButton(onPressed: _pickDriver, child: const Text('Choose')),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickStartDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Start date', border: OutlineInputBorder()),
                        child: Text(_dateFormat.format(_startDate)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickEndDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'End date', border: OutlineInputBorder()),
                        child: Text(_endDate == null ? 'Indefinite' : _dateFormat.format(_endDate!)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppTextField(controller: _notes, label: 'Notes', hint: 'Optional', maxLines: 2),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active'),
                value: _status,
                onChanged: (value) => setState(() => _status = value),
              ),
              if (formState.failure != null) ...[
                const SizedBox(height: 8),
                Text(formState.failure!.message, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              PrimaryButton(
                label: isEditing ? 'Save Changes' : 'Add Standing Order',
                busy: formState.submitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const ShellTabBar(),
    );
  }
}

class _CustomerPickerField extends ConsumerWidget {
  const _CustomerPickerField({required this.chosen, required this.onChosen});

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
            child: Text('Selected: ${chosen!.fullName}', style: const TextStyle(color: Colors.grey)),
          ),
      ],
    );
  }
}

class _DriverPickerSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_DriverPickerSheet> createState() => _DriverPickerSheetState();
}

class _DriverPickerSheetState extends ConsumerState<_DriverPickerSheet> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(driverPickerControllerProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Preferred driver', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),
          TextField(
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Search drivers'),
            onChanged: (value) => ref.read(driverPickerControllerProvider.notifier).search(value),
          ),
          const SizedBox(height: 12),
          if (state.loading) const LinearProgressIndicator(),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final driver in state.options)
                  ListTile(
                    title: Text(driver.fullName),
                    onTap: () => Navigator.pop(context, driver),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
