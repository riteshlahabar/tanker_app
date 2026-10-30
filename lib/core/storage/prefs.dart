import 'package:shared_preferences/shared_preferences.dart';

/// Small, non-secret preferences — the theme choice and whether the
/// walkthrough has been seen. Tokens never come here; they live in
/// [SecureStorage].
class Prefs {
  const Prefs(this._prefs);

  final SharedPreferences _prefs;

  static const _darkModeKey = 'isDarkModeOnPref';
  static const _onDutyKey = 'isOnDutyPref';

  bool get isDarkMode => _prefs.getBool(_darkModeKey) ?? false;

  Future<void> setDarkMode(bool value) => _prefs.setBool(_darkModeKey, value);

  /// Whether the buzzer's on-duty service should run — remembered so a driver
  /// who went on duty yesterday does not find out at noon that the app was
  /// never watching.
  ///
  /// Here rather than on the account because it is a fact about **this
  /// phone**: the handset in the cab is on duty, and the same driver's second
  /// device should not quietly start a service of its own.
  bool get isOnDuty => _prefs.getBool(_onDutyKey) ?? false;

  Future<void> setOnDuty(bool value) => _prefs.setBool(_onDutyKey, value);
}
