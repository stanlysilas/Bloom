import 'package:bloom/core/theme/colors.dart';
import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  colorScheme: blueLightColorScheme,
  useMaterial3: true,
  scaffoldBackgroundColor: blueLightColorScheme.surface,
);

final ThemeData darkTheme = ThemeData(
  colorScheme: blueDarkColorScheme,
  useMaterial3: true,
  scaffoldBackgroundColor: blueDarkColorScheme.surface,
);
