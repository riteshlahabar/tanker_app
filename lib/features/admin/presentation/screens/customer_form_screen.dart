import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/active_switch_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/form_note.dart';
import '../../../../shared/widgets/form_section_heading.dart';
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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Three questions, grouped: who they are, how they sign in,
              // and where the water goes. One undifferentiated stack of eight
              // fields made the address — the one every booking falls back
              // to — look like an afterthought at the bottom.
              const FormSectionHeading('Who they are'),
              AppTextField(
                controller: _firstName,
                label: 'First name',
                hint: '',
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _lastName,
                label: 'Last name',
                hint: 'Optional',
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _mobile,
                label: 'Mobile',
                hint: 'Ten digits',
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 6),
              const FormNote('This is what the customer signs in to the app with.'),

              const FormSectionHeading('App sign-in'),
              AppTextField(
                controller: _password,
                label: isEditing ? 'New password (optional)' : 'Password',
                hint: isEditing ? 'Leave blank to keep the current one' : 'At least 8 characters',
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

              const FormSectionHeading('Where the water goes'),
              AppTextField(
                controller: _address,
                label: 'Delivery address',
                hint: 'House, street, area',
                maxLines: 3,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 6),
              const FormNote(
                'Every order this customer places falls back to this address, so it is '
                'required. They can still type a different one for a one-off delivery.',
              ),

              const FormSectionHeading('How they order'),
              _SelfOrderCard(
                value: _canSelfOrder,
                onChanged: (value) => setState(() => _canSelfOrder = value),
              ),
              const SizedBox(height: 12),
              ActiveSwitchCard(
                value: _status,
                onChanged: (value) => setState(() => _status = value),
                activeNote: 'Can sign in and appears on the New Order screen.',
                inactiveNote: 'Cannot sign in, and no new order can be written for them.',
              ),
              if (formState.failure != null) ...[
                const SizedBox(height: 12),
                Text(
                  formState.failure!.message,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
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

/// Whether the customer may place their own orders, said as a consequence
/// rather than a switch labelled with a rule number — "off" here means the
/// app refuses an order they try to place, which is not something a bare
/// toggle communicates.
class _SelfOrderCard extends StatelessWidget {
  const _SelfOrderCard({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      decoration: BoxDecoration(
        color: appetitAppContainerColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(
            value ? Icons.phone_iphone : Icons.event_repeat,
            size: 20,
            color: appTextColorSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value ? 'Orders from the app' : 'Fixed routine',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  value
                      ? 'They book their own tankers whenever they need one.'
                      : 'The office manages their deliveries; the app refuses an order they place.',
                  style: const TextStyle(fontSize: 12, color: appTextColorSecondary),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
