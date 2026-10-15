/// Safe readers for the panel's JSON.
///
/// The one that matters: PHP's `json_encode` writes an integral float as
/// `1200`, not `1200.0`, so every money and distance field arrives as `num`
/// and may be an `int`. Casting such a value with `as double` throws at
/// runtime — [asDouble] is the only way these fields should be read.
class JsonRead {
  JsonRead._();

  static double asDouble(Object? value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;

    return fallback;
  }

  static double? asDoubleOrNull(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);

    return null;
  }

  static int asInt(Object? value, {int fallback = 0}) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;

    return fallback;
  }

  static int? asIntOrNull(Object? value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);

    return null;
  }

  static String asString(Object? value, {String fallback = ''}) =>
      value == null ? fallback : value.toString();

  static String? asStringOrNull(Object? value) => value?.toString();

  static bool asBool(Object? value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';

    return fallback;
  }

  static DateTime? asDate(Object? value) {
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);

    return null;
  }

  static Map<String, dynamic> asMap(Object? value) =>
      value is Map<String, dynamic> ? value : const {};

  static List<Map<String, dynamic>> asMapList(Object? value) => value is List
      ? value.whereType<Map<String, dynamic>>().toList(growable: false)
      : const [];
}
