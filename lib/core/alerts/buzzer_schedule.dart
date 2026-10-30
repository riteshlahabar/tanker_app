/// When the buzzer sounds, and when it has said enough.
///
/// The owner's rule in words: **ring for a minute, remind three times while
/// the order is still unseen, then go quiet.** Going quiet costs nothing —
/// the order stays on the screen and, with the duty service running, in the
/// notification shade — so the only thing lost is noise nobody is acting on.
///
/// Plain arithmetic on purpose. The rule is the part worth testing, and a
/// test that had to own an [AudioPlayer] would be testing the plugin instead.
class BuzzerSchedule {
  BuzzerSchedule._();

  /// The first burst, the one that has to be heard over a running engine.
  static const Duration firstBurst = Duration(seconds: 60);

  /// A reminder is deliberately much shorter: by then the phone has already
  /// rung for a minute, so this is a nudge, not a second alarm.
  static const Duration reminderBurst = Duration(seconds: 15);

  static const Duration quietBetween = Duration(minutes: 2);

  static const int reminders = 3;

  /// Whether the buzzer should be sounding [since] after the app first saw
  /// this order in the alert list.
  ///
  /// Measured from **first sighting**, not from the order's `created_at`: an
  /// app that was shut when the order was written must still get its full
  /// minute when it opens, and an order placed while the phone was in a
  /// tunnel must not arrive already past its own reminders.
  static bool ringingAt(Duration since) {
    if (since.isNegative) return false;

    var burstStart = Duration.zero;

    for (var burst = 0; burst <= reminders; burst++) {
      final length = burst == 0 ? firstBurst : reminderBurst;

      // Past the start of a burst but short of its end is the only ringing
      // state; short of its start is the quiet gap before it.
      if (since < burstStart + length) return since >= burstStart;

      burstStart += length + quietBetween;
    }

    return false;
  }

  /// How long an unseen order stays noisy — 7 min 45 s, after which the
  /// alert is silent but still on screen.
  static Duration get runsFor => firstBurst + (quietBetween + reminderBurst) * reminders;
}
