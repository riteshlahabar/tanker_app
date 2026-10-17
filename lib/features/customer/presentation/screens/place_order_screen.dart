import 'package:flutter/material.dart';

import '../widgets/place_order_form.dart';

/// The Order tab's body. The shell supplies the Scaffold and app bar, so this
/// is the form alone; the pushed route version is [BookTankerScreen].
class PlaceOrderScreen extends StatelessWidget {
  const PlaceOrderScreen({super.key});

  @override
  Widget build(BuildContext context) => const PlaceOrderForm();
}
