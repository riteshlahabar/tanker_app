import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/auth_user.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/providers/session_controller.dart';
import '../../features/auth/presentation/providers/session_state.dart';
import '../widgets/app_text_field.dart';
import '../widgets/on_duty_card.dart';
import '../widgets/primary_button.dart';

/// View/edit account details, change password, logout — identical for every
/// role, so each role shell's Profile tab points at this one screen rather
/// than keeping its own copy.
class AccountProfileScreen extends ConsumerStatefulWidget {
  const AccountProfileScreen({super.key});

  @override
  ConsumerState<AccountProfileScreen> createState() => _AccountProfileScreenState();
}

class _AccountProfileScreenState extends ConsumerState<AccountProfileScreen> {
  bool _editing = false;
  bool _savingProfile = false;
  bool _savingPassword = false;
  String? _profileError;
  String? _passwordError;

  late final _firstName = TextEditingController();
  late final _lastName = TextEditingController();
  late final _address = TextEditingController();

  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _address.dispose();
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _startEditing(String firstName, String lastName, String address) {
    _firstName.text = firstName;
    _lastName.text = lastName;
    _address.text = address;
    setState(() {
      _editing = true;
      _profileError = null;
    });
  }

  Future<void> _saveProfile() async {
    setState(() {
      _savingProfile = true;
      _profileError = null;
    });

    final result = await ref.read(authRepositoryProvider).updateProfile(
          firstName: _firstName.text.trim(),
          lastName: _lastName.text.trim(),
          address: _address.text.trim(),
        );

    if (!mounted) return;

    result.when(
      success: (user) {
        ref.read(sessionControllerProvider.notifier).signedIn(SessionSignedIn(user));
        setState(() {
          _savingProfile = false;
          _editing = false;
        });
      },
      error: (failure) => setState(() {
        _savingProfile = false;
        _profileError = failure.message;
      }),
    );
  }

  Future<void> _changePassword() async {
    setState(() {
      _savingPassword = true;
      _passwordError = null;
    });

    final result = await ref.read(authRepositoryProvider).changePassword(
          currentPassword: _currentPassword.text,
          password: _newPassword.text,
          passwordConfirmation: _confirmPassword.text,
        );

    if (!mounted) return;

    result.when(
      success: (message) {
        _currentPassword.clear();
        _newPassword.clear();
        _confirmPassword.clear();
        setState(() => _savingPassword = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message.isEmpty ? 'Password changed.' : message)));
      },
      error: (failure) => setState(() {
        _savingPassword = false;
        _passwordError = failure.message;
      }),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Stay')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Log out')),
        ],
      ),
    );

    if (confirmed ?? false) {
      await ref.read(sessionControllerProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    final user = session is SessionSignedIn ? session.user : null;

    if (user == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CircleAvatar(radius: 36, child: Text(user.initials, style: const TextStyle(fontSize: 22))),
        const SizedBox(height: 12),
        Center(
          child: Text(user.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ),
        if (user.mobile != null)
          Center(child: Text(user.mobile!, style: const TextStyle(color: Colors.grey))),
        const SizedBox(height: 24),
        if (_editing) ..._editingFields() else ..._readOnlyFields(user),
        const SizedBox(height: 16),
        // Renders nothing for a customer, who is never rung.
        const OnDutyCard(),
        const Divider(height: 40),
        const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        AppTextField(controller: _currentPassword, label: 'Current password', hint: '', obscureText: true),
        const SizedBox(height: 12),
        AppTextField(controller: _newPassword, label: 'New password', hint: '', obscureText: true),
        const SizedBox(height: 12),
        AppTextField(controller: _confirmPassword, label: 'Confirm new password', hint: '', obscureText: true),
        if (_passwordError != null) ...[
          const SizedBox(height: 8),
          Text(_passwordError!, style: const TextStyle(color: Colors.red)),
        ],
        const SizedBox(height: 16),
        PrimaryButton(label: 'Change Password', busy: _savingPassword, onPressed: _changePassword),
        const SizedBox(height: 32),
        OutlinedButton(onPressed: _logout, child: const Text('Log Out')),
      ],
    );
  }

  List<Widget> _readOnlyFields(AuthUser user) {
    final salary = user.monthlySalary;

    return [
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.location_on_outlined),
        title: Text(user.address ?? 'No address on file'),
        trailing: TextButton(
          onPressed: () => _startEditing(user.firstName, user.lastName, user.address ?? ''),
          child: const Text('Edit'),
        ),
      ),
      // Drivers only, and read-only: the office sets it. Null means the
      // signed-in account is not a driver at all, so the row is absent rather
      // than showing a salary of zero to a customer.
      if (salary != null)
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.payments_outlined),
          title: Text('₹ ${salary.toStringAsFixed(0)}'),
          subtitle: const Text('Monthly salary'),
        ),
    ];
  }

  List<Widget> _editingFields() {
    return [
      AppTextField(controller: _firstName, label: 'First name', hint: ''),
      const SizedBox(height: 12),
      AppTextField(controller: _lastName, label: 'Last name', hint: ''),
      const SizedBox(height: 12),
      AppTextField(controller: _address, label: 'Address', hint: '', maxLines: 3),
      if (_profileError != null) ...[
        const SizedBox(height: 8),
        Text(_profileError!, style: const TextStyle(color: Colors.red)),
      ],
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _editing = false),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PrimaryButton(label: 'Save', busy: _savingProfile, onPressed: _saveProfile),
          ),
        ],
      ),
    ];
  }
}
