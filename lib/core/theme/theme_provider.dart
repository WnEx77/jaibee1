import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _prefKey = 'isDarkTheme';

  bool _isDarkTheme = false;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  /// Returns if dark theme is enabled
  bool get isDarkTheme => _isDarkTheme;

  /// Returns the corresponding ThemeMode (used in MaterialApp)
  ThemeMode get themeMode => _isDarkTheme ? ThemeMode.dark : ThemeMode.light;

  /// Toggle the theme and persist it
  void toggleTheme(bool isOn) {
    _isDarkTheme = isOn;
    _saveThemeToPrefs(isOn);
    notifyListeners();
  }

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkTheme = prefs.getBool(_prefKey) ?? false;
    notifyListeners();
  }

  Future<void> _saveThemeToPrefs(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
  }
}
