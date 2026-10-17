import 'package:flutter/material.dart';

import '../../../../shared/widgets/shell_tab_bar.dart';
import '../widgets/place_order_form.dart';

/// The booking form as a pushed screen, opened by Home's "Book a Tanker"
/// button.
///
/// It carries its own Scaffold and app bar because a pushed route has neither:
/// the shell's Scaffold belongs to the route underneath, and a form with no
/// Material above it throws rather than drawing.
class BookTankerScreen extends StatelessWidget {
  const BookTankerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book a Tanker')),
      body: const PlaceOrderForm(replaceSelfOnPlaced: true),
      bottomNavigationBar: const ShellTabBar(),
    );
  }
}
