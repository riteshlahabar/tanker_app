import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';

/// Shown while the stored token is checked against the panel. It is a real
/// screen rather than a blank frame, so a slow network looks deliberate.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.water_drop, size: 72, color: appColorPrimary),
            SizedBox(height: 24),
            Text('Tanker', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500)),
            SizedBox(height: 32),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
          ],
        ),
      ),
    );
  }
}
