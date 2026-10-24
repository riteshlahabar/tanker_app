import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/active_switch_card.dart';
import '../../../../shared/widgets/app_dropdown_field.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/form_error_note.dart';
import '../../../../shared/widgets/form_note.dart';
import '../../../../shared/widgets/form_section_heading.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/shell_tab_bar.dart';
import '../../domain/admin_driver.dart';
import '../../domain/admin_tanker.dart';
import '../providers/admin_driver_form_controller.dart';
import '../providers/admin_providers.dart';

/// Create (no [existing]) or edit a driver.
class DriverFormScreen extends ConsumerStatefulWidget {
  const DriverFormScreen({super.key, this.existing});

  final AdminDriver? existing;

  @override
  ConsumerState<DriverFormScreen> createState() => _DriverFormScreenState();
}

class _DriverFormScreenState extends ConsumerState<DriverFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _firstName = TextEditingController(text: widget.existing?.firstName);
  late final _lastName = TextEditingController(text: widget.existing?.lastName);
  late final _mobile = TextEditingController(text: widget.existing?.mobile);
  final _password = TextEditingController();
  final _passwordConfirmation = TextEditingController();
  // Blank for a zero salary, matching DriverListTile's "Salary not set": the
  // figure every driver carries today is an omission, not a decision, so
  // pre-filling 0 would invite saving it straight back unchanged.
  late final _salary = TextEditingController(
    text: (widget.existing?.monthlySalary ?? 0) == 0
        ? ''
        : widget.existing!.monthlySalary.toStringAsFixed(0),
  );
  late final _address = TextEditingController(text: widget.existing?.address);
  late bool _status = widget.existing?.status ?? true;
  int? _tankerId;
  List<AdminTanker> _tankerOptions = const [];

  @override
  void initState() {
    super.initState();
    _tankerId = widget.existing?.tanker?.id;
    _loadTankers();
  }

  Future<void> _loadTankers() async {
    final result = await ref
        .read(adminTankerRepositoryProvider)
        .unassigned(keepTankerId: widget.existing?.tanker?.id);

    if (!mounted) return;

    setState(() => _tankerOptions = result.valueOrNull ?? const []);
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _mobile.dispose();
    _password.dispose();
    _passwordConfirmation.dispose();
    _salary.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref.read(adminDriverFormControllerProvider.notifier).submit(
          {
            'first_name': _firstName.text.trim(),
            'last_name': _lastName.text.trim(),
            'mobile': _mobile.text.trim(),
            if (_password.text.isNotEmpty) 'password': _password.text,
            if (_password.text.isNotEmpty) 'password_confirmation': _passwordConfirmation.text,
            'tanker_id': ?_tankerId,
            'monthly_salary': double.tryParse(_salary.text.trim()) ?? 0,
            'address': _address.text.trim().isEmpty ? null : _address.text.trim(),
            'status': _status,
          },
          id: widget.existing?.id,
        );

    if (!mounted) return;

    final saved = ref.read(adminDriverFormControllerProvider).saved;

    if (saved == null) return;

    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this driver?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await ref.read(adminDriverRepositoryProvider).delete(widget.existing!.id);

    if (!mounted) return;

    result.when(
      success: (_) => Navigator.of(context).pop(),
      error: (failure) =>
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(adminDriverFormControllerProvider);
    final isEditing = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Driver' : 'Add Driver'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete driver',
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
              // Grouped rather than one undifferentiated stack of nine fields:
              // who the person is, how they sign in, what they drive and what
              // they are paid are four different questions, and the form reads
              // as a wall of boxes without the split.
              const FormSectionHeading('Who they are'),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _firstName,
                      label: 'First name',
                      hint: '',
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _lastName,
                      label: 'Last name',
                      hint: 'Optional',
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppTextField(controller: _address, label: 'Address', hint: 'Optional', maxLines: 2),
              const FormSectionHeading('How they sign in'),
              AppTextField(
                controller: _mobile,
                label: 'Mobile',
                hint: 'Ten digits',
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              // Ten digits, not 91-prefixed: this is what the driver types at
              // login, and the panel qualifies it to 91 itself before sending
              // any WhatsApp message.
              const FormNote('The driver logs into the app with this number. Store ten digits.'),
              const SizedBox(height: 12),
              AppTextField(
                controller: _password,
                label: isEditing ? 'New password' : 'Password',
                hint: isEditing ? 'Leave blank to keep the current one' : '',
                obscureText: true,
                validator: (v) => (!isEditing && (v == null || v.isEmpty)) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _passwordConfirmation,
                label: 'Confirm password',
                hint: isEditing ? 'Only if changing it' : '',
                obscureText: true,
                validator: (v) => (_password.text.isNotEmpty && v != _password.text)
                    ? 'Passwords do not match'
                    : null,
              ),
              const FormSectionHeading('What they drive'),
              AppDropdownField<int?>(
                label: 'Tanker',
                value: _tankerId,
                icon: Icons.local_shipping_outlined,
                items: [
                  const DropdownMenuItem(value: null, child: Text('No tanker')),
                  ..._tankerOptions.map(
                    (tanker) => DropdownMenuItem(value: tanker.id, child: Text(tanker.label)),
                  ),
                ],
                onChanged: (value) => setState(() => _tankerId = value),
              ),
              const SizedBox(height: 8),
              const FormNote(
                'Only unassigned tankers are listed, plus the one this driver '
                'already holds. A driver with no tanker cannot be given an order.',
              ),
              const FormSectionHeading('What they are paid'),
              AppTextField(
                controller: _salary,
                label: 'Monthly salary (₹)',
                hint: 'Required',
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              const FormNote(
                'A whole month, not a rate per delivery. It is never divided '
                'across deliveries, never recorded on an order, and never '
                'prorated in a report.',
              ),
              const SizedBox(height: 20),
              ActiveSwitchCard(
                value: _status,
                onChanged: (value) => setState(() => _status = value),
                activeNote: 'Can log in and be assigned orders',
                inactiveNote: 'Cannot log in or be given new orders',
              ),
              if (formState.failure != null) ...[
                const SizedBox(height: 12),
                FormErrorNote(formState.failure!.message),
              ],
              const SizedBox(height: 24),
              PrimaryButton(
                label: isEditing ? 'Save Changes' : 'Add Driver',
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
