import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

/// A small capitalised heading that splits a form into groups of related
/// questions — the same treatment the admin dashboard uses over its TODAY /
/// COMING UP / ON THE BOOKS blocks, so a grouped form and a grouped dashboard
/// read as one piece of design.
///
/// Shared rather than private to one screen: it was written for the Tanker
/// form, and every form the design pass reaches needs the identical heading.
class FormSectionHeading extends StatelessWidget {
  const FormSectionHeading(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10, left: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: appTextColorSecondary,
        ),
      ),
    );
  }
}
