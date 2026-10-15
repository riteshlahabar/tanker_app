import 'package:flutter/material.dart';

/// appetit's login heading, type scale kept exactly: 45px title at w500 and a
/// 15px w300 line under it.
class LoginHeading extends StatelessWidget {
  const LoginHeading({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 45, fontWeight: FontWeight.w500)),
        const SizedBox(height: 16),
        Text(subtitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w300)),
      ],
    );
  }
}
