import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Phase 3: keeping the buzzer alive when the app is minimised.
///
/// **It does not poll, and it does not ring.** Android freezes a backgrounded
/// app's isolate within minutes, which is what stops phase 2 dead with no
/// sign that it has stopped. A foreground service keeps the process out of
/// that freeze, so the ordinary `Timer`s in `OrderAlertsController` keep
/// firing and the ring-and-stop logic stays in exactly one place — the thing
/// `docs/2026-10-27-part-3.md` promised, so that FCM can later replace the
/// wake-up without touching the alert itself.
///
/// The task isolate therefore does almost nothing: a heartbeat that nudges
/// the main isolate, and the notification's Stop button. It deliberately does
/// **not** read the token or call the API — two isolates refreshing the same
/// Sanctum pair would race each other into signing the driver out.
///
/// Honest limits, which the Settings card states to the driver in these
/// words: Xiaomi, Oppo, Vivo and Realme kill background services unless the
/// app is whitelisted, and the "on duty" notification cannot be dismissed
/// while it runs.
class DutyService {
  DutyService._();

  static const String channelId = 'wtms_on_duty';

  /// What the task isolate sends the main one; both are plain strings so the
  /// platform's data channel needs no codec of ours.
  static const String heartbeat = 'duty.heartbeat';
  static const String stopPressed = 'duty.stop';

  /// The notification button's id, matched in [_DutyTaskHandler].
  static const String stopButtonId = 'stop';

  /// Once per app start, before any start/stop call.
  static void configure() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: channelId,
        channelName: 'On duty',
        channelDescription: 'Shown while WTMS is watching for new orders.',
        // LOW on purpose: this notification is a status line, not the alert.
        // The alert is the buzzer, and a channel that chimed every time the
        // text changed would be the first thing a driver switched off.
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        playSound: false,
        enableVibration: false,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        // 30 s, not the poll's 15: this only has to keep the process warm and
        // nudge a poll that may have drifted. The real timing lives in
        // OrderAlertsController.
        eventAction: ForegroundTaskEventAction.repeat(30000),
        allowWakeLock: true,
        allowWifiLock: true,
        // A driver who swipes the app away has gone off duty in every sense
        // the word has; leaving a service running after that is how an app
        // earns a reputation for eating battery.
        stopWithTask: true,
      ),
    );
  }

  static Future<bool> get isRunning => FlutterForegroundTask.isRunningService;

  /// Ask for what the service needs. Returns false when the driver says no,
  /// so the caller can leave the toggle off rather than claim to be on duty.
  static Future<bool> requestPermissions() async {
    final notifications = await FlutterForegroundTask.checkNotificationPermission();

    if (notifications != NotificationPermission.granted) {
      final granted = await FlutterForegroundTask.requestNotificationPermission();

      if (granted != NotificationPermission.granted) return false;
    }

    // Asked but not insisted on: without it the OEM may still kill the
    // service, but a driver who refuses should still get what we can give.
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }

    return true;
  }

  static Future<bool> start() async {
    if (await isRunning) return true;

    final result = await FlutterForegroundTask.startService(
      serviceId: 2610,
      serviceTypes: const [ForegroundServiceTypes.dataSync],
      notificationTitle: 'On duty',
      notificationText: 'Watching for new orders.',
      notificationButtons: const [NotificationButton(id: stopButtonId, text: 'Stop alert')],
      callback: dutyCallback,
    );

    return result is ServiceRequestSuccess;
  }

  static Future<void> stop() async {
    if (!await isRunning) return;

    await FlutterForegroundTask.stopService();
  }

  /// Put what is waiting into the notification itself, so a glance at the
  /// shade answers the question without unlocking the phone.
  ///
  /// Called from the poll, so it has to be harmless when there is no service
  /// and no platform at all — off duty, on a desktop build, in a test.
  static Future<void> describe({required int waiting}) async {
    try {
      if (!await isRunning) return;

      await FlutterForegroundTask.updateService(
        notificationTitle: waiting > 0 ? 'New order waiting' : 'On duty',
        notificationText: switch (waiting) {
          0 => 'Watching for new orders.',
          1 => '1 order has not been opened yet.',
          _ => '$waiting orders have not been opened yet.',
        },
      );
    } catch (_) {
      // The notification is a convenience; the buzzer is the alert.
    }
  }
}

/// The task isolate's entry point. Must be top-level and annotated, or the
/// release build's tree-shaker removes it and the service starts into nothing.
@pragma('vm:entry-point')
void dutyCallback() {
  FlutterForegroundTask.setTaskHandler(_DutyTaskHandler());
}

class _DutyTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {
    FlutterForegroundTask.sendDataToMain(DutyService.heartbeat);
  }

  @override
  void onNotificationButtonPressed(String id) {
    if (id == DutyService.stopButtonId) {
      FlutterForegroundTask.sendDataToMain(DutyService.stopPressed);
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}
}
