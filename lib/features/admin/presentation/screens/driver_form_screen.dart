import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
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
  late final _rate =
      TextEditingController(text: widget.existing?.perDeliveryRate.toStringAsFixed(0) ?? '');
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
    _rate.dispose();
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
            'per_delivery_rate': double.tryParse(_rate.text.trim()) ?? 0,
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
              AppTextField(
                controller: _firstName,
                label: 'First name',
                hint: '',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(controller: _lastName, label: 'Last name', hint: 'Optional'),
              const SizedBox(height: 12),
              AppTextField(
                controller: _mobile,
                label: 'Mobile',
                hint: '',
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _password,
                label: isEditing ? 'New password (optional)' : 'Password',
                hint: '',
                obscureText: true,
                validator: (v) =>
                    (!isEditing && (v == null || v.isEmpty)) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _passwordConfirmation,
                label: 'Confirm password',
                hint: '',
                obscureText: true,
                validator: (v) => (_password.text.isNotEmpty && v != _password.text)
                    ? 'Passwords do not match'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                initialValue: _tankerId,
                decoration: const InputDecoration(labelText: 'Tanker', border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem(value: null, child: Text('No tanker')),
                  ..._tankerOptions.map(
                    (tanker) => DropdownMenuItem(value: tanker.id, child: Text(tanker.label)),
                  ),
                ],
                onChanged: (value) => setState(() => _tankerId = value),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _rate,
                label: 'Per-delivery rate',
                hint: '',
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(controller: _address, label: 'Address', hint: 'Optional', maxLines: 3),
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
                label: isEditing ? 'Save Changes' : 'Add Driver',
                busy: formState.submitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
