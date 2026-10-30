import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

/// The thing that makes the noise.
///
/// An interface rather than a concrete player so the alert state machine can
/// be tested without a platform channel: [OrderAlertsController] decides
/// *when* to ring, this decides *how*, and the two are worth testing apart.
abstract interface class Buzzer {
  /// Start sounding. Must be safe to call while already sounding — the
  /// controller re-asserts the state on every tick rather than tracking
  /// edges, so a second call has to be a no-op and not a second loop.
  Future<void> start();

  Future<void> stop();

  Future<void> dispose();
}

/// Loops `assets/sounds/buzzer.wav` on the **alarm** stream, with the phone
/// vibrating along with it.
class LoopingBuzzer implements Buzzer {
  LoopingBuzzer();

  /// audioplayers prefixes `assets/` itself, so this is the path below it.
  static const String _asset = 'sounds/buzzer.wav';

  /// Roughly the sound's own rhythm, so the two do not fight each other.
  /// `repeat: 0` loops the pattern from its first entry.
  static const List<int> _vibration = [0, 180, 70, 180, 1770];

  final AudioPlayer _player = AudioPlayer();

  bool _sounding = false;

  /// Asked once and remembered: a tablet in the office has no vibrator, and
  /// asking on every ring is a platform call for an answer that cannot change.
  bool? _canVibrate;

  @override
  Future<void> start() async {
    if (_sounding) return;

    _sounding = true;

    // Deliberately not awaited together: if audio fails the vibration must
    // still happen, which is the whole point of having both.
    await _sound();
    await _buzz();
  }

  Future<void> _sound() async {
    try {
      // The alarm usage, not media. A driver's media volume is routinely 0 —
      // podcasts off, phone in a cradle — and a buzzer nobody can hear is
      // worse than no buzzer, because the office believes it rang.
      await _player.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.alarm,
            // Transient, not gain: when the order is acknowledged whatever
            // was playing before should come back on its own.
            audioFocus: AndroidAudioFocus.gainTransient,
            stayAwake: true,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: const {AVAudioSessionOptions.duckOthers},
          ),
        ),
      );
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(1);
      await _player.play(AssetSource(_asset));
    } catch (_) {
      // No audio route, a locked-down device, a stream the OS refused: the
      // vibration and the banner still do their job, and an exception thrown
      // out of here would take the whole poll tick down with it.
    }
  }

  Future<void> _buzz() async {
    try {
      _canVibrate ??= await Vibration.hasVibrator();

      if (_canVibrate ?? false) {
        await Vibration.vibrate(pattern: _vibration, repeat: 0);
      }
    } catch (_) {
      // Same reasoning as _sound: a missing motor is not an error worth
      // propagating into the alert loop.
    }
  }

  @override
  Future<void> stop() async {
    if (!_sounding) return;

    _sounding = false;

    try {
      await _player.stop();
    } catch (_) {
      // Nothing to stop is the state we wanted anyway.
    }

    try {
      await Vibration.cancel();
    } catch (_) {
      // As above.
    }
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _player.dispose();
  }
}

/// A buzzer that does nothing, for tests and for a role that is never rung.
class SilentBuzzer implements Buzzer {
  const SilentBuzzer();

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}
