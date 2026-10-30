import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/core/alerts/buzzer_schedule.dart';

void main() {
  group('BuzzerSchedule', () {
    test('rings for the first minute', () {
      expect(BuzzerSchedule.ringingAt(Duration.zero), isTrue);
      expect(BuzzerSchedule.ringingAt(const Duration(seconds: 30)), isTrue);
      expect(BuzzerSchedule.ringingAt(const Duration(seconds: 59)), isTrue);
    });

    test('goes quiet the moment the first minute is up', () {
      expect(BuzzerSchedule.ringingAt(const Duration(seconds: 60)), isFalse);
      expect(BuzzerSchedule.ringingAt(const Duration(seconds: 90)), isFalse);
    });

    test('reminds three times, and only three times', () {
      // Each reminder is a 15 s burst two minutes after the last one ended.
      final reminderStarts = [
        const Duration(seconds: 180),
        const Duration(seconds: 315),
        const Duration(seconds: 450),
      ];

      for (final start in reminderStarts) {
        expect(BuzzerSchedule.ringingAt(start), isTrue, reason: 'reminder at ${start.inSeconds}s');
        expect(BuzzerSchedule.ringingAt(start + const Duration(seconds: 14)), isTrue);
        expect(BuzzerSchedule.ringingAt(start + const Duration(seconds: 15)), isFalse);
        expect(BuzzerSchedule.ringingAt(start - const Duration(seconds: 1)), isFalse);
      }

      // What a fourth reminder would have been.
      expect(BuzzerSchedule.ringingAt(const Duration(seconds: 585)), isFalse);
    });

    test('stops for good once it has said enough', () {
      expect(BuzzerSchedule.runsFor, const Duration(seconds: 465));
      expect(BuzzerSchedule.ringingAt(BuzzerSchedule.runsFor), isFalse);
      expect(BuzzerSchedule.ringingAt(const Duration(hours: 3)), isFalse);
    });

    test('an order with a clock in the future is silent, not ringing for ever', () {
      // A phone whose clock jumps forward mid-shift must not be read as "this
      // alert has not started yet, keep asking".
      expect(BuzzerSchedule.ringingAt(const Duration(seconds: -5)), isFalse);
    });
  });
}
