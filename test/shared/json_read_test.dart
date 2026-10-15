import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/shared/utils/json_read.dart';

void main() {
  group('JsonRead.asDouble', () {
    // The trap this guards: PHP's json_encode writes an integral float as
    // `1200`, so money and distance fields arrive as int and `as double`
    // would throw at runtime.
    test('reads an int that the panel sent for a money field', () {
      expect(JsonRead.asDouble(1200), 1200.0);
      expect(JsonRead.asDouble(1200), isA<double>());
    });

    test('reads a real double unchanged', () {
      expect(JsonRead.asDouble(1200.5), 1200.5);
    });

    test('reads a decimal cast that arrived as a string', () {
      expect(JsonRead.asDouble('1200.50'), 1200.5);
    });

    test('falls back rather than throwing on null or rubbish', () {
      expect(JsonRead.asDouble(null), 0.0);
      expect(JsonRead.asDouble('not a number'), 0.0);
      expect(JsonRead.asDouble(null, fallback: -1), -1.0);
    });

    test('asDoubleOrNull keeps null null, for an unset latitude', () {
      expect(JsonRead.asDoubleOrNull(null), isNull);
      expect(JsonRead.asDoubleOrNull(19), 19.0);
    });
  });

  group('JsonRead.asBool', () {
    test('accepts the shapes a Laravel boolean cast can take', () {
      expect(JsonRead.asBool(true), isTrue);
      expect(JsonRead.asBool(1), isTrue);
      expect(JsonRead.asBool('1'), isTrue);
      expect(JsonRead.asBool('true'), isTrue);
      expect(JsonRead.asBool(0), isFalse);
      expect(JsonRead.asBool(null), isFalse);
    });
  });

  group('JsonRead.asMapList', () {
    test('returns an empty list rather than throwing on a missing array', () {
      expect(JsonRead.asMapList(null), isEmpty);
      expect(JsonRead.asMapList('nonsense'), isEmpty);
    });

    test('keeps only the object rows', () {
      expect(
        JsonRead.asMapList([
          {'id': 1},
          'junk',
          {'id': 2},
        ]).length,
        2,
      );
    });
  });
}
