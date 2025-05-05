import 'package:bloom/required_data/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColorSchemeProvider with ChangeNotifier {
  static const String _colorSchemeKey = 'selectedColorScheme';

  ColorSchemeProvider() {
    _loadColorFromPreferences();
  }

  late Color _primaryColor;

  Color get primaryColor => _primaryColor;

  set primaryColor(Color newColor) {
    _primaryColor = newColor;
    _saveColorToPreferences(newColor);
    notifyListeners();
  }

  Future<void> _saveColorToPreferences(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_colorSchemeKey, colorToHex(color));
  }

  Future<void> _loadColorFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedColorHex = prefs.getString(_colorSchemeKey);

    if (savedColorHex != null) {
      _primaryColor = hexToColor(savedColorHex);
    } else {
      // Use theme-based default color
      _primaryColor = _getDefaultColor();
    }

    notifyListeners();
  }

  /// Get the default color based on the current theme
  Color _getDefaultColor() {
    return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark
        ? primaryColorDarkMode
        : primaryColorLightMode;
  }

  /// Converts a Color to a hex string (e.g., "FF2196F3" for blue)
  String colorToHex(Color color) => color.toHexString();

  /// Converts a hex string back to a Color object
  Color hexToColor(String hex) => Color(int.parse(hex, radix: 16));
}
