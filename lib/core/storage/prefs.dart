import 'package:shared_preferences/shared_preferences.dart';

/// Small, non-secret preferences — the theme choice and whether the
/// walkthrough has been seen. Tokens never come here; they live in
/// [SecureStorage].
class Prefs {
  const Prefs(this._prefs);

  final SharedPreferences _prefs;

  static const _darkModeKey = 'isDarkModeOnPref';

  bool get isDarkMode => _prefs.getBool(_darkModeKey) ?? false;

  Future<void> setDarkMode(bool value) => _prefs.setBool(_darkModeKey, value);
}
