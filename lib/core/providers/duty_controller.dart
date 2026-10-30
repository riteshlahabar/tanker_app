import 'dart:async';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/providers/session_controller.dart';
import '../../features/auth/presentation/providers/session_state.dart';
import '../../shared/models/user_role.dart';
import '../alerts/duty_service.dart';
import 'core_providers.dart';
import 'order_alerts_controller.dart';

part 'duty_controller.g.dart';

class DutyState {
  const DutyState({this.onDuty = false, this.available = false, this.busy = false});

  /// Whether the foreground service is running.
  final bool onDuty;

  /// Whether this role is ever rung at all — the toggle is hidden otherwise.
  final bool available;

  /// True while a start or stop is in flight, so the switch cannot be
  /// double-tapped into a service the app has lost track of.
  final bool busy;

  DutyState copyWith({bool? onDuty, bool? available, bool? busy}) => DutyState(
        onDuty: onDuty ?? this.onDuty,
        available: available ?? this.available,
        busy: busy ?? this.busy,
      );
}

/// The on-duty toggle: phase 3's switch, and the bridge between the task
/// isolate and the alert controller that already knows how to ring.
///
/// The choice is remembered, so a driver who went on duty yesterday is on
/// duty again when the app opens rather than discovering at noon that it was
/// never watching. It is remembered **per device**, in [Prefs] — being on
/// duty is a fact about the phone in the cab, not about the account, and the
/// same driver's second handset should not start a service of its own.
@Riverpod(keepAlive: true)
class DutyController extends _$DutyController {
  @override
  DutyState build() {
    final session = ref.watch(sessionControllerProvider);
    final role = session is SessionSignedIn ? session.user.role : null;
    final available = role == UserRole.admin || role == UserRole.driver;

    ref.onDispose(() => FlutterForegroundTask.removeTaskDataCallback(_fromTask));

    if (available) {
      Future<void>.microtask(_restore);
    } else {
      // Signing out, or signing in as a customer, must not leave a service
      // running against nobody.
      Future<void>.microtask(_shutDown);
    }

    return DutyState(available: available);
  }

  /// What the task isolate sends us. Both messages are handled here, in the
  /// main isolate, because this is where the buzzer and the token live.
  void _fromTask(Object data) {
    final controller = ref.read(orderAlertsControllerProvider.notifier);

    switch (data) {
      // A nudge, not the poll itself: the poll's own timer is the primary,
      // and this only matters if it drifted while the process was idle.
      case DutyService.heartbeat:
        unawaited(controller.refresh());
      // The notification's Stop button, which acknowledges the order for the
      // same reason the banner's does — see OrderAlertsController.stopAll.
      case DutyService.stopPressed:
        unawaited(controller.stopAll());
    }
  }

  Future<void> _restore() async {
    // Every line here is a platform call. On a desktop or web build, and in
    // any widget test that mounts the Profile screen, there is nothing on the
    // other end — and a toggle that cannot be offered has to read as "off",
    // not take the screen down with it.
    try {
      FlutterForegroundTask.initCommunicationPort();
      FlutterForegroundTask.addTaskDataCallback(_fromTask);

      // The service may have survived the app — a restart, or Android
      // rebuilding the activity — so what it is actually doing wins over what
      // was last written down.
      if (await DutyService.isRunning) {
        state = state.copyWith(onDuty: true);

        return;
      }

      if (ref.read(prefsProvider).isOnDuty) await setOnDuty(true);
    } catch (_) {
      state = state.copyWith(onDuty: false);
    }
  }

  Future<void> _shutDown() async {
    try {
      await DutyService.stop();
    } catch (_) {
      // As in _restore: no platform, nothing to stop.
    }

    state = state.copyWith(onDuty: false);
  }

  /// Set once the service has actually been started, so a later stop is not
  /// a platform call into something that was never there.
  bool _sawServiceStart = false;

  /// Returns a message to show when the request could not be granted, and
  /// null when it worked.
  Future<String?> setOnDuty(bool value) async {
    if (state.busy) return null;

    state = state.copyWith(busy: true);

    try {
      if (!value) {
        if (_sawServiceStart) await DutyService.stop();

        await ref.read(prefsProvider).setOnDuty(false);

        state = state.copyWith(onDuty: false);

        return null;
      }

      if (!await DutyService.requestPermissions()) {
        return 'WTMS needs notification permission to stay on duty.';
      }

      if (!await DutyService.start()) {
        return 'Android would not start the on-duty service.';
      }

      _sawServiceStart = true;

      await ref.read(prefsProvider).setOnDuty(true);

      state = state.copyWith(onDuty: true);

      await DutyService.describe(waiting: ref.read(orderAlertsControllerProvider).alerts.length);

      return null;
    } finally {
      state = state.copyWith(busy: false);
    }
  }
}
