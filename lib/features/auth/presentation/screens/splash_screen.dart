import 'package:flutter/material.dart';

/// Shown while the stored token is checked against the panel. It is a real
/// screen rather than a blank frame, so a slow network looks deliberate.
///
/// [AuthGate] holds it for a fixed five seconds; the screen itself is
/// unchanged from the original — logo on the theme's own white ground.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/images/tsml_logo.png'),
              width: 260,
            ),
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
