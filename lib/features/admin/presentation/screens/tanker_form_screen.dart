import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/widgets/active_switch_card.dart';
import '../../../../shared/widgets/app_picker_field.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/form_error_note.dart';
import '../../../../shared/widgets/form_note.dart';
import '../../../../shared/widgets/form_section_heading.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/shell_tab_bar.dart';
import '../../domain/admin_tanker.dart';
import '../providers/admin_providers.dart';
import '../providers/admin_tanker_form_controller.dart';

/// Create (no [existing]) or edit a tanker.
class TankerFormScreen extends ConsumerStatefulWidget {
  const TankerFormScreen({super.key, this.existing});

  final AdminTanker? existing;

  @override
  ConsumerState<TankerFormScreen> createState() => _TankerFormScreenState();
}

class _TankerFormScreenState extends ConsumerState<TankerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _vehicleName = TextEditingController(text: widget.existing?.vehicleName);
  late final _vehicleNumber = TextEditingController(text: widget.existing?.vehicleNumber);
  late final _capacity =
      TextEditingController(text: widget.existing?.capacityLitres?.toString() ?? '');
  // Blank for a null *or* zero rate, matching TankerListTile: both mean "no
  // rate of its own", so pre-filling 0.00 would contradict the card that
  // just said "Rate not set".
  late final _rate = TextEditingController(
    text: (widget.existing?.tankerRate ?? 0) == 0
        ? ''
        : widget.existing!.tankerRate!.toStringAsFixed(2),
  );
  late final _modelYear =
      TextEditingController(text: widget.existing?.modelYear?.toString() ?? '');
  late final _rcNumber = TextEditingController(text: widget.existing?.rcNumber);
  final _notes = TextEditingController();
  DateTime? _insuranceExpiry;
  late bool _status = widget.existing?.status ?? true;

  static final _dateFormat = DateFormat('d MMM yyyy');

  @override
  void initState() {
    super.initState();
    _insuranceExpiry = widget.existing?.insuranceExpiry;
  }

  @override
  void dispose() {
    _vehicleName.dispose();
    _vehicleNumber.dispose();
    _capacity.dispose();
    _rate.dispose();
    _modelYear.dispose();
    _rcNumber.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickInsuranceExpiry() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _insuranceExpiry ?? DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );

    if (picked != null) setState(() => _insuranceExpiry = picked);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final insuranceExpiry =
        _insuranceExpiry == null ? null : DateFormat('yyyy-MM-dd').format(_insuranceExpiry!);

    await ref.read(adminTankerFormControllerProvider.notifier).submit(
          {
            'vehicle_name': _vehicleName.text.trim(),
            'vehicle_number': _vehicleNumber.text.trim(),
            'tanker_rate': ?double.tryParse(_rate.text.trim()),
            'capacity_litres': ?int.tryParse(_capacity.text.trim()),
            'model_year': ?int.tryParse(_modelYear.text.trim()),
            'rc_number': _rcNumber.text.trim().isEmpty ? null : _rcNumber.text.trim(),
            'insurance_expiry': ?insuranceExpiry,
            'notes': _notes.text.trim().isEmpty ? null : _notes.text.trim(),
            'status': _status,
          },
          id: widget.existing?.id,
        );

    if (!mounted) return;

    final saved = ref.read(adminTankerFormControllerProvider).saved;

    if (saved == null) return;

    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this tanker?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await ref.read(adminTankerRepositoryProvider).delete(widget.existing!.id);

    if (!mounted) return;

    result.when(
      success: (_) => Navigator.of(context).pop(),
      error: (failure) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }


  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(adminTankerFormControllerProvider);
    final isEditing = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Tanker' : 'Add Tanker'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete tanker',
              onPressed: _delete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grouped rather than one undifferentiated stack of seven
              // fields: what identifies the vehicle, what it charges, and the
              // paperwork are three different questions, and only the first
              // two are required.
              const FormSectionHeading('The vehicle'),
              AppTextField(
                controller: _vehicleNumber,
                label: 'Vehicle number',
                hint: 'e.g. MH12AB1234',
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _vehicleName,
                label: 'Vehicle name',
                hint: 'What the office calls it',
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _capacity,
                      label: 'Capacity (L)',
                      hint: 'Optional',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _modelYear,
                      label: 'Model year',
                      hint: 'Optional',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const FormSectionHeading('What it charges'),
              AppTextField(
                controller: _rate,
                label: 'Rate per tanker (₹)',
                hint: 'Blank uses the Price per Tanker setting',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              const FormNote(
                // Capacity sits in the section above on purpose: water is sold
                // by the load, so litres are vehicle information and have no
                // bearing on the price.
                'One load from this vehicle. Leave it blank and the order falls '
                'back to the Price per Tanker setting, then to the flat default.',
              ),
              const FormSectionHeading('Paperwork'),
              AppTextField(
                controller: _rcNumber,
                label: 'RC number',
                hint: 'Optional',
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              AppPickerField(
                label: 'Insurance expiry',
                hint: 'Optional',
                icon: Icons.event_outlined,
                value: _insuranceExpiry == null ? null : _dateFormat.format(_insuranceExpiry!),
                onTap: _pickInsuranceExpiry,
                onClear: () => setState(() => _insuranceExpiry = null),
              ),
              const SizedBox(height: 12),
              AppTextField(controller: _notes, label: 'Notes', hint: 'Optional', maxLines: 2),
              const SizedBox(height: 20),
              ActiveSwitchCard(
                value: _status,
                onChanged: (value) => setState(() => _status = value),
                activeNote: 'Available to be assigned to a driver',
                inactiveNote: 'Hidden from driver assignment',
              ),
              if (formState.failure != null) ...[
                const SizedBox(height: 12),
                FormErrorNote(formState.failure!.message),
              ],
              const SizedBox(height: 24),
              PrimaryButton(
                label: isEditing ? 'Save Changes' : 'Add Tanker',
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
