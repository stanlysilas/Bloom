import 'package:bloom/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const _themePreferenceKey = 'themeSchemeValue';
  static const _colorSchemePreferenceKey = 'selectedColorSchemeIndex';

  String _themeValue = 'system';
  int _accentIndex = 0;

  ThemeData _themeData = ThemeData();

  ThemeProvider() {
    _loadPreferences();
  }

  ThemeData get themeData => _themeData;

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _themeValue = prefs.getString(_themePreferenceKey) ?? 'system';
    _accentIndex = prefs.getInt(_colorSchemePreferenceKey) ?? 0;
    _buildTheme();
  }

  void _buildTheme() {
    final isDark = _themeValue == 'dark' ||
        (_themeValue == 'system' &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);

    final colorScheme = _getColorScheme(isDark);
    _themeData = ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: colorScheme.surface,
        fontFamily: 'Nunito');
    notifyListeners();
  }

  ColorScheme _getColorScheme(bool isDark) {
    switch (_accentIndex) {
      case 0:
        return isDark ? blueDarkColorScheme : blueLightColorScheme;
      // Add future palettes here:
      case 1:
        return isDark ? greenDarkColorScheme : greenLightColorScheme;
      case 2:
        return isDark ? amberDarkColorScheme : amberLightColorScheme;
      case 3:
        return isDark ? crimsonDarkColorScheme : crimsonLightColorScheme;
      case 4:
        return isDark ? obsidianDarkColorScheme : obsidianLightColorScheme;
      case 5:
        return isDark ? purpleDarkColorScheme : purpleLightColorScheme;
      default:
        return isDark ? blueDarkColorScheme : blueLightColorScheme;
    }
  }

  void setTheme(String value) async {
    _themeValue = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePreferenceKey, value);
    _buildTheme();
  }

  void setAccent(int index) async {
    _accentIndex = index;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_colorSchemePreferenceKey, index);
    _buildTheme();
  }

  void toggleTheme() {
    if (_themeValue == 'light') {
      setTheme('dark');
    } else if (_themeValue == 'dark') {
      setTheme('system');
    } else {
      setTheme('light');
    }
  }
}
