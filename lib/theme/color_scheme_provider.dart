import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'colors.dart'; // contains all your ColorSchemes

class ColorSchemeProvider with ChangeNotifier {
  static const String _schemeKey = 'selectedColorSchemeIndex';

  ColorScheme _currentScheme = blueLightColorScheme;
  int _selectedSchemeIndex = 0;

  int get selectedSchemeIndex => _selectedSchemeIndex;
  ColorScheme get currentScheme => _currentScheme;

  /// List of all color families with light/dark variants
  final List<Map<String, ColorScheme>> _colorSchemes = [
    {
      'light': blueLightColorScheme,
      'dark': blueDarkColorScheme,
    },
    {
      'light': greenLightColorScheme,
      'dark': greenDarkColorScheme,
    },
    {
      'light': amberLightColorScheme,
      'dark': amberDarkColorScheme,
    },
    {
      'light': crimsonLightColorScheme,
      'dark': crimsonDarkColorScheme,
    },
    {
      'light': obsidianLightColorScheme,
      'dark': obsidianDarkColorScheme,
    },
    {
      'light': purpleLightColorScheme,
      'dark': purpleDarkColorScheme,
    }
  ];

  /// Corresponding display names for the color families
  final List<String> _schemeNames = [
    'Default Blue',
    'Nature Green',
    'Momentum Amber',
    'Crimson Serenity',
    'Obsidian Focus',
    'Lavender Muse',
  ];

  List<String> get schemeNames => _schemeNames;

  ColorSchemeProvider() {
    loadSchemeFromPreferences();
  }

  Future<void> loadSchemeFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedSchemeIndex = prefs.getInt(_schemeKey) ?? 0;

    final isDark =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;

    _currentScheme = isDark
        ? _colorSchemes[_selectedSchemeIndex]['dark']!
        : _colorSchemes[_selectedSchemeIndex]['light']!;
    notifyListeners();
  }

  Future<void> setColorScheme(int index) async {
    _selectedSchemeIndex = index;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_schemeKey, index);

    final isDark =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;

    _currentScheme =
        isDark ? _colorSchemes[index]['dark']! : _colorSchemes[index]['light']!;
    notifyListeners();
  }
}
