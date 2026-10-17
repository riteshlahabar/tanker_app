import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';

/// The login card's heading.
///
/// appetit's own is a 45px w500 title; inside a centred card that is too tall
/// for the space, so the size drops to 28 while the weight, the 15px w300
/// sub-line and the spacing between them stay the design's.
class LoginHeading extends StatelessWidget {
  const LoginHeading({
    super.key,
    required this.title,
    this.subtitle,
    this.centered = false,
  });

  final String title;

  /// Omitted on the login screen itself — the title carries it. Left optional
  /// rather than removed so the sub-line keeps its design if it is wanted back.
  final String? subtitle;

  final bool centered;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: TextStyle(fontSize: centered ? 28 : 45, fontWeight: FontWeight.w500),
        ),
        if (subtitle case final String line) ...[
          const SizedBox(height: 10),
          Text(
            line,
            textAlign: centered ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w300,
              color: isDark ? iconColorSecondaryDark : appTextColorSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
