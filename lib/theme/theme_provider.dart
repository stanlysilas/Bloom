import 'package:bloom/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themePreferenceKey = 'themeSchemeValue';

  ThemeProvider() {
    _loadThemeFromPreferences();
  }

  String _themeValue = 'system';  // Default to system theme
  ThemeData _themeData = lightTheme;

  ThemeData get themeData => _themeData;
  String get theme => _themeValue;

  set theme(String value) {
    _themeValue = value;
    _themeData = _getThemeFromValue(value);
    _saveThemeToPreferences(value);
    notifyListeners();
  }

  Future<void> _saveThemeToPreferences(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePreferenceKey, theme);
  }

  Future<void> _loadThemeFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _themeValue = prefs.getString(_themePreferenceKey) ?? 'system';
    _themeData = _getThemeFromValue(_themeValue);
    notifyListeners();
  }

  ThemeData _getThemeFromValue(String value) {
    switch (value) {
      case 'light':
        return lightTheme;
      case 'dark':
        return darkTheme;
      default:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark
            ? darkTheme
            : lightTheme;
    }
  }

  void toggleTheme() {
    if (_themeValue == 'light') {
      theme = 'dark';
    } else if (_themeValue == 'dark') {
      theme = 'system';
    } else {
      theme = 'light';
    }
  }
}
