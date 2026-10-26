import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/shell_tab_bar.dart';
import '../../domain/admin_customer.dart';
import '../providers/admin_customer_form_controller.dart';
import '../providers/admin_providers.dart';

/// Create (no [existing]) or edit a customer.
class CustomerFormScreen extends ConsumerStatefulWidget {
  const CustomerFormScreen({super.key, this.existing});

  final AdminCustomer? existing;

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _firstName = TextEditingController(text: widget.existing?.firstName);
  late final _lastName = TextEditingController(text: widget.existing?.lastName);
  late final _mobile = TextEditingController(text: widget.existing?.mobile);
  final _password = TextEditingController();
  final _passwordConfirmation = TextEditingController();
  late final _address = TextEditingController(text: widget.existing?.address);
  late final _latitude =
      TextEditingController(text: widget.existing?.latitude?.toString() ?? '');
  late final _longitude =
      TextEditingController(text: widget.existing?.longitude?.toString() ?? '');
  late bool _canSelfOrder = widget.existing?.canSelfOrder ?? true;
  late bool _status = widget.existing?.status ?? true;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _mobile.dispose();
    _password.dispose();
    _passwordConfirmation.dispose();
    _address.dispose();
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref.read(adminCustomerFormControllerProvider.notifier).submit(
          {
            'first_name': _firstName.text.trim(),
            'last_name': _lastName.text.trim(),
            'mobile': _mobile.text.trim(),
            if (_password.text.isNotEmpty) 'password': _password.text,
            if (_password.text.isNotEmpty) 'password_confirmation': _passwordConfirmation.text,
            'address': _address.text.trim(),
            'latitude': ?double.tryParse(_latitude.text.trim()),
            'longitude': ?double.tryParse(_longitude.text.trim()),
            'can_self_order': _canSelfOrder,
            'status': _status,
          },
          id: widget.existing?.id,
        );

    if (!mounted) return;

    final saved = ref.read(adminCustomerFormControllerProvider).saved;

    if (saved == null) return;

    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this customer?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await ref.read(adminCustomerRepositoryProvider).delete(widget.existing!.id);

    if (!mounted) return;

    result.when(
      success: (_) => Navigator.of(context).pop(),
      error: (failure) =>
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(adminCustomerFormControllerProvider);
    final isEditing = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Customer' : 'Add Customer'),
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
              AppTextField(
                controller: _address,
                label: 'Address',
                hint: 'Every order the customer places falls back to this',
                maxLines: 3,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
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
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Can place own orders'),
                subtitle: const Text('Off = deliveries are a fixed routine the office manages'),
                value: _canSelfOrder,
                onChanged: (value) => setState(() => _canSelfOrder = value),
              ),
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
                label: isEditing ? 'Save Changes' : 'Add Customer',
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
