import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/providers/session_controller.dart';
import '../../features/auth/presentation/providers/session_state.dart';
import '../../shared/models/order.dart';
import '../../shared/models/user_role.dart';
import '../alerts/buzzer_schedule.dart';
import '../alerts/duty_service.dart';
import 'core_providers.dart';
import 'opened_order.dart';

part 'order_alerts_controller.g.dart';

/// What is ringing, and whether the noise is on.
class OrderAlertsState {
  const OrderAlertsState({
    this.alerts = const [],
    this.ringing = false,
    this.watching = false,
  });

  /// Unseen, still-open orders written for this user — oldest first, as the
  /// panel sends them.
  final List<Order> alerts;

  /// Whether the buzzer is sounding right now. False while an alert is still
  /// listed but has run through its reminders.
  final bool ringing;

  /// Whether the poll is running. False for a customer, and for a session
  /// that is still being restored.
  final bool watching;

  /// The one to put in front of the user: the longest-ignored.
  Order? get loudest => alerts.isEmpty ? null : alerts.first;

  bool get hasAlerts => alerts.isNotEmpty;

  OrderAlertsState copyWith({
    List<Order>? alerts,
    bool? ringing,
    bool? watching,
  }) =>
      OrderAlertsState(
        alerts: alerts ?? this.alerts,
        ringing: ringing ?? this.ringing,
        watching: watching ?? this.watching,
      );
}

/// The buzzer: a new order rings on the other side until it is seen.
///
/// Two timers, deliberately not one:
///
///  * a **poll** asking the panel what is still unseen. The server owns that
///    fact (`orders.alert_for` / `alert_seen_at`), which is what stops an
///    order re-ringing after a reinstall, on a second device, or when the
///    token refreshes;
///  * a **tick** that re-asserts "should it be sounding now" against
///    [BuzzerSchedule]. It re-asserts rather than tracking edges, so a missed
///    tick cannot leave the phone ringing for ever.
///
/// First sighting is kept **here, per order id**, not read off the order: the
/// minute of ringing belongs to the moment this phone learned about the job,
/// not to the moment the row was written. An app that was shut, or a phone in
/// a tunnel, still gets its full minute when it comes back.
///
/// Phase 3 adds no second code path: the duty service simply keeps the
/// process awake so these timers keep firing with the app minimised.
@Riverpod(keepAlive: true)
class OrderAlertsController extends _$OrderAlertsController {
  Timer? _poll;
  Timer? _tick;

  /// When this app first saw each ringing order.
  final Map<int, DateTime> _firstSeen = {};

  /// Whether the buzzer has ever actually been asked to sound.
  ///
  /// Guards every "stop" path: `buzzerProvider` builds a real [AudioPlayer],
  /// and stopping something that never started would construct one — on a
  /// customer's phone, which is never rung, and in every widget test that
  /// happens to mount a screen reading this provider.
  bool _sounded = false;

  /// Ids a local action has silenced. Kept so the next poll — which may have
  /// been in flight when Stop was pressed — cannot bring the noise back
  /// before the server's answer catches up.
  final Set<int> _silenced = {};

  static const Duration _pollEvery = Duration(seconds: 15);
  static const Duration _tickEvery = Duration(seconds: 1);

  @override
  OrderAlertsState build() {
    final session = ref.watch(sessionControllerProvider);
    final role = session is SessionSignedIn ? session.user.role : null;

    // Only the two roles the owner named are ever rung. A customer's own
    // order rings nobody, so a customer has no poll to run.
    final watched = role == UserRole.admin || role == UserRole.driver;

    // Opening an order silences it. Heard rather than asked for, so that an
    // order detail screen does not have to depend on the session — see
    // [OpenedOrder].
    ref.listen(openedOrderProvider, (_, mark) {
      if (mark != null) unawaited(seenIfAlerting(mark.orderId));
    });

    ref.onDispose(_stopTimers);

    if (watched) {
      // Never from inside build(): the first thing _refresh does is read
      // `state`, and reading it here throws into a swallowed future and
      // leaves the alert silently dead.
      Future<void>.microtask(_begin);
    } else {
      // Signing out, or signing in as a customer, must not leave a phone
      // ringing about somebody else's order.
      _stopTimers();
      _silence();
    }

    return OrderAlertsState(watching: watched);
  }

  void _begin() {
    _poll ??= Timer.periodic(_pollEvery, (_) => unawaited(_refresh()));
    _tick ??= Timer.periodic(_tickEvery, (_) => _applySchedule());

    unawaited(_refresh());
  }

  void _stopTimers() {
    _poll?.cancel();
    _tick?.cancel();
    _poll = null;
    _tick = null;
  }

  /// Ask the panel what is still unseen.
  Future<void> _refresh() async {
    final result = await ref.read(orderAlertsRepositoryProvider).pending();

    result.when(
      success: (orders) {
        // The server's list is the truth about *what* is alerting; the
        // locally silenced ids only hide the gap until it agrees.
        final listed = orders.where((o) => !_silenced.contains(o.id)).toList(growable: false);
        final ids = orders.map((o) => o.id).toSet();

        // An order that has dropped off the list — seen, delivered,
        // cancelled or handed to another driver — forgets its clock, so if it
        // ever comes back it gets a fresh minute rather than arriving silent.
        _firstSeen.removeWhere((id, _) => !ids.contains(id));
        _silenced.removeWhere((id) => !ids.contains(id));

        final now = DateTime.now();

        for (final order in listed) {
          _firstSeen.putIfAbsent(order.id, () => now);
        }

        state = state.copyWith(alerts: listed);

        // The shade is a view of this list, so it is written from here — the
        // one place that knows what is waiting — rather than by the duty
        // toggle listening back. It is a no-op unless the service is running.
        unawaited(DutyService.describe(waiting: listed.length));

        _applySchedule();
      },
      // A failed poll changes nothing. No connection is not "nothing is
      // waiting", and clearing the list on a timeout would silence a job
      // the driver has not seen.
      error: (_) {},
    );
  }

  /// Should it be sounding, right now?
  void _applySchedule() {
    final now = DateTime.now();

    final shouldRing = state.alerts.any((order) {
      final since = _firstSeen[order.id];

      return since != null && BuzzerSchedule.ringingAt(now.difference(since));
    });

    if (shouldRing == state.ringing) return;

    if (shouldRing) {
      _sounded = true;
      unawaited(ref.read(buzzerProvider).start());
    } else {
      _silence();
    }

    state = state.copyWith(ringing: shouldRing);
  }

  void _silence() {
    if (!_sounded) return;

    unawaited(ref.read(buzzerProvider).stop());
  }

  /// The recipient has looked at the order — from opening it, or from the
  /// Stop action, which the owner asked to count as having seen it.
  ///
  /// Silenced here first and told to the panel second: the noise has to stop
  /// on the tap, not on the round trip.
  Future<void> markSeen(int orderId) async {
    _silenced.add(orderId);
    _firstSeen.remove(orderId);

    state = state.copyWith(
      alerts: state.alerts.where((order) => order.id != orderId).toList(growable: false),
    );

    _applySchedule();

    await ref.read(orderAlertsRepositoryProvider).markSeen(orderId);

    // Confirm against the server rather than trusting the local edit — this
    // is also what picks up anything that arrived during the round trip.
    await _refresh();
  }

  /// Stop the noise for everything currently waiting. The owner's Stop action
  /// acknowledges the lot, which is why it marks them seen rather than just
  /// muting: a silent order nobody has seen is the one failure mode this
  /// whole feature exists to prevent.
  Future<void> stopAll() async {
    for (final order in state.alerts.toList(growable: false)) {
      await markSeen(order.id);
    }
  }

  /// Called when an order's detail screen opens, from whichever list the
  /// recipient reached it by. A no-op unless that order is actually ringing,
  /// so every other order detail costs nothing.
  Future<void> seenIfAlerting(int orderId) async {
    if (!state.alerts.any((order) => order.id == orderId)) return;

    await markSeen(orderId);
  }

  /// For a pull-to-refresh and for the duty service's heartbeat.
  Future<void> refresh() => _refresh();
}
