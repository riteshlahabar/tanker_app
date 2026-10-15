import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../providers/login_controller.dart';
import '../widgets/login_error_banner.dart';
import '../widgets/login_heading.dart';

/// The one login screen for all three roles — the panel works out from the
/// username whether this is the owner's email or a driver's or customer's
/// mobile number, and the router opens the matching shell.
///
/// Layout, spacing and type are appetit's login screen: 16px page padding, a
/// 60px gap above a 45px heading, cream 15px-radius fields, and a 60px
/// orange action at the foot.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.notice});

  /// Why the previous session ended — an expired refresh token, or an
  /// account the owner switched off. Shown until the user edits a field.
  final String? notice;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final outcome = await ref.read(loginControllerProvider.notifier).submit(
          username: _username.text,
          password: _password.text,
        );

    if (!mounted || !outcome.accepted) return;

    // The router is watching the session, so it swaps the shell in; this
    // screen only says hello.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Welcome back, ${outcome.session!.user.fullName}.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
    final controller = ref.read(loginControllerProvider.notifier);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const LoginHeading(
                title: 'Login',
                subtitle: 'Sign in to manage your tanker deliveries',
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: AppTextField(
                        controller: _username,
                        label: 'Mobile number or e-mail',
                        hint: 'Drivers and customers use their mobile number',
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        enabled: !state.submitting,
                        errorText: state.errorFor('username'),
                        onChanged: (_) => controller.fieldChanged(),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty) ? 'Enter your mobile or e-mail' : null,
                      ),
                    ),
                    AppTextField(
                      controller: _password,
                      label: 'Enter Password',
                      hint: 'Enter your Password',
                      obscureText: state.obscurePassword,
                      textInputAction: TextInputAction.done,
                      enabled: !state.submitting,
                      errorText: state.errorFor('password'),
                      onChanged: (_) => controller.fieldChanged(),
                      validator: (value) =>
                          (value == null || value.isEmpty) ? 'Enter your password' : null,
                      suffixIcon: IconButton(
                        onPressed: controller.togglePasswordVisibility,
                        icon: Icon(
                          state.obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (state.generalError ?? widget.notice case final String message) ...[
                const SizedBox(height: 16),
                LoginErrorBanner(message: message),
              ],
              const Spacer(),
              PrimaryButton(
                label: 'Login',
                busy: state.submitting,
                onPressed: _submit,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
