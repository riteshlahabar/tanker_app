import 'package:flutter/material.dart';

/// The design's main call to action: full width, 60 high, 15px radius, in
/// appetit's orange — the login screen's Login button, reused wherever a
/// screen has one primary action.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.icon,
  });

  final String label;

  /// Null disables the button, which is how a form blocks submit until it is
  /// valid.
  final VoidCallback? onPressed;

  /// Swaps the label for a spinner and blocks a second tap.
  final bool busy;

  final IconData? icon;

  /// appetit's login button colour, kept exactly.
  static final Color background = Colors.orange.shade700;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: busy ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          disabledBackgroundColor: background.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: busy
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(label, style: const TextStyle(fontSize: 18, color: Colors.white)),
                ],
              ),
      ),
    );
  }
}
