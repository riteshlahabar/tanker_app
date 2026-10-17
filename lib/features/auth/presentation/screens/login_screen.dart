import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../providers/login_controller.dart';
import '../providers/login_state.dart';
import '../widgets/login_error_banner.dart';
import '../widgets/login_heading.dart';

/// The one login screen for all three roles — the panel works out from the
/// username whether this is the owner's email or a driver's or customer's
/// mobile number, and the router opens the matching shell.
///
/// The card is centred rather than pinned to the top: on a tall phone a
/// top-anchored form leaves a bank of empty space under the button, and on a
/// short one the old `Spacer` pushed the action off the fold. Centring with a
/// scroll view behind it reads the same on both, and the keyboard pushes the
/// card up instead of overlapping it.
///
/// Colour, radius and type stay the design's: cream 15px-radius fields, the
/// 60px orange action, and the plum the bars use as the ground.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? appBackgroundColorDark : appLayout_background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: ConstrainedBox(
              // So the form does not stretch into one long line on a tablet.
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _card(context, state, controller, isDark),
                  const SizedBox(height: 20),
                  Text(
                    'Water Tanker Management System',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark ? iconColorSecondaryDark : appTextColorSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(
    BuildContext context,
    LoginState state,
    LoginController controller,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
      decoration: BoxDecoration(
        color: isDark ? cardBackgroundBlackDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: isDark ? appShadowColorDark : appShadowColor,
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const LoginHeading(title: 'Welcome back', centered: true),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
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
                const SizedBox(height: 16),
                AppTextField(
                  controller: _password,
                  label: 'Enter Password',
                  hint: 'Enter your Password',
                  obscureText: state.obscurePassword,
                  textInputAction: TextInputAction.done,
                  enabled: !state.submitting,
                  errorText: state.errorFor('password'),
                  onChanged: (_) => controller.fieldChanged(),
                  validator: (value) => (value == null || value.isEmpty) ? 'Enter your password' : null,
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
          const SizedBox(height: 26),
          PrimaryButton(
            label: 'Login',
            busy: state.submitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
