import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/spot.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/active_switch_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/form_note.dart';
import '../../../../shared/widgets/form_section_heading.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/shell_tab_bar.dart';
import '../providers/admin_providers.dart';
import '../providers/admin_spot_form_controller.dart';

/// Create (no [existing]) or edit a refill spot.
class SpotFormScreen extends ConsumerStatefulWidget {
  const SpotFormScreen({super.key, this.existing});

  final Spot? existing;

  @override
  ConsumerState<SpotFormScreen> createState() => _SpotFormScreenState();
}

class _SpotFormScreenState extends ConsumerState<SpotFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _address = TextEditingController(text: widget.existing?.address);
  late final _refillCharge =
      TextEditingController(text: widget.existing?.refillCharge.toStringAsFixed(0) ?? '');
  late final _waterType = TextEditingController(text: widget.existing?.waterType);
  late final _contactPerson = TextEditingController(text: widget.existing?.contactPerson);
  late final _contactMobile = TextEditingController(text: widget.existing?.contactMobile);
  late bool _isAvailable = widget.existing?.isAvailable ?? true;
  late bool _status = widget.existing?.status ?? true;

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _refillCharge.dispose();
    _waterType.dispose();
    _contactPerson.dispose();
    _contactMobile.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref.read(adminSpotFormControllerProvider.notifier).submit(
          {
            'name': _name.text.trim(),
            'address': _address.text.trim(),
            'refill_charge': double.tryParse(_refillCharge.text.trim()) ?? 0,
            'water_type': _waterType.text.trim().isEmpty ? null : _waterType.text.trim(),
            'contact_person': _contactPerson.text.trim(),
            'contact_mobile': _contactMobile.text.trim(),
            'is_available': _isAvailable,
            'status': _status,
          },
          id: widget.existing?.id,
        );

    if (!mounted) return;

    final saved = ref.read(adminSpotFormControllerProvider).saved;

    if (saved == null) return;

    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this filling point?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await ref.read(adminSpotRepositoryProvider).delete(widget.existing!.id);

    if (!mounted) return;

    result.when(
      success: (_) => Navigator.of(context).pop(),
      error: (failure) =>
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(adminSpotFormControllerProvider);
    final isEditing = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Filling Point' : 'Add Filling Point'),
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
              const FormSectionHeading('The point'),
              AppTextField(
                controller: _name,
                label: 'Name',
                hint: 'e.g. Hadapsar Borewell',
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _address,
                label: 'Address',
                hint: 'How the driver finds it',
                maxLines: 3,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 6),
              const FormNote(
                'Required: the address is the only thing that says where this point is.',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _refillCharge,
                      label: 'Refill charge (₹)',
                      hint: 'Per fill',
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _waterType,
                      label: 'Water type',
                      hint: 'Borewell, RO',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const FormNote('The refill charge is snapshotted onto each order filled here.'),

              const FormSectionHeading('Who to ring'),
              AppTextField(
                controller: _contactPerson,
                label: 'Contact person',
                hint: 'Who keeps the point',
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _contactMobile,
                label: 'Contact mobile',
                hint: 'e.g. 9876543210',
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 6),
              const FormNote('The driver rings this if the point is shut or the queue is long.'),

              const FormSectionHeading('Right now'),
              _AvailabilityCard(
                value: _isAvailable,
                onChanged: (value) => setState(() => _isAvailable = value),
              ),
              const SizedBox(height: 12),
              ActiveSwitchCard(
                value: _status,
                onChanged: (value) => setState(() => _status = value),
                activeNote: 'Offered on the order and assign screens.',
                inactiveNote: 'Hidden everywhere; existing orders keep the charge already saved.',
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
                label: isEditing ? 'Save Changes' : 'Add Filling Point',
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

/// Available today or not — a different question from Active, and the one the
/// driver feels: an unavailable point is skipped on the route even though the
/// owner still keeps it on the books.
class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final accent = value ? statusDeliveredColor : statusPendingColor;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      decoration: BoxDecoration(
        color: appetitAppContainerColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value ? 'Available' : 'Unavailable',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  value
                      ? 'A driver can fill here today.'
                      : 'Dry, shut or queued — not offered for a refill today.',
                  style: const TextStyle(fontSize: 12, color: appTextColorSecondary),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeTrackColor: accent),
        ],
      ),
    );
  }
}
