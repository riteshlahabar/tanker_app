import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'opened_order.g.dart';

/// Which order's detail screen was opened last.
typedef OpenedOrderMark = ({int orderId, int seq});

/// "An order detail screen just opened" — announced here, and acted on by
/// whoever cares.
///
/// The buzzer stops when the recipient *opens* the order, and they may well
/// reach it from their orders list or the dashboard having heard the phone and
/// gone looking. So the two detail controllers have to say that they opened,
/// and the alert controller has to hear it.
///
/// The dependency runs **this way round** on purpose. Having the detail
/// controllers read the alert controller instead made every order detail
/// depend on the signed-in session, and so on secure storage — which took
/// three unrelated unit tests down with "Binding has not yet been
/// initialized". This provider depends on nothing, and nothing but the alert
/// controller listens to it, so for a customer — who is never rung — the
/// announcement simply falls on no ears.
///
/// [seq] exists so that opening the same order twice is two events rather
/// than one unchanged value a listener would never be told about.
@Riverpod(keepAlive: true)
class OpenedOrder extends _$OpenedOrder {
  @override
  OpenedOrderMark? build() => null;

  void opened(int orderId) => state = (orderId: orderId, seq: (state?.seq ?? 0) + 1);
}
