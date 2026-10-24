import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

/// A quiet line under a field, for a rule the owner would otherwise have to be
/// told once and then remember — what a blank value falls back to, what a
/// number does and does not mean.
class FormNote extends StatelessWidget {
  const FormNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: appTextColorSecondary, height: 1.35),
      ),
    );
  }
}
