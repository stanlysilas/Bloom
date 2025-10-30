import 'package:flutter/material.dart';

// ====================
// ==== BLUE TONES ====
// ====================
const ColorScheme blueLightColorScheme = ColorScheme(
  brightness: Brightness.light,

  // === Primary (Brand color) ===
  primary: Color(0xFF89A9EF), // soft blue - core brand color
  onPrimary: Colors.white,
  primaryContainer: Color(0xFFCEDCFF), // slightly lighter for containers
  onPrimaryContainer: Color(0xFF0D285C),

  // === Secondary (Neutral accent, no green hue) ===
  secondary: Color(0xFF7D8FB3), // desaturated blue-grey
  onSecondary: Colors.white,
  secondaryContainer: Color(0xFFCCD6EB), // muted bluish tone for chips/buttons
  onSecondaryContainer: Color(0xFF14223E),

  // === Tertiary (Cool subtle highlight) ===
  tertiary: Color(0xFF6A92B3),
  onTertiary: Colors.white,
  tertiaryContainer: Color(0xFFD9EBF6),
  onTertiaryContainer: Color(0xFF072535),

  // === Error ===
  error: Color(0xFFD84444),
  onError: Colors.white,
  errorContainer: Color(0xFFF9DADA),
  onErrorContainer: Color(0xFF690006),

  // === Background & Surface ===
  background: Color(0xFFF7F9FB),
  onBackground: Color(0xFF1A1C1E),

  surface: Color(0xFFF7F9FB),
  onSurface: Color(0xFF1A1C1E),

  surfaceVariant: Color(0xFFE1E4EC),
  onSurfaceVariant: Color(0xFF44484F),

  // === Surface Containers (Elevation tones) ===
  surfaceContainerLowest: Color(0xFFFAFBFD), // lightest - dialogs/cards
  surfaceContainerLow: Color(0xFFF2F4F8), // elevated sheet bg
  surfaceContainer: Color(0xFFE6EAF1), // navbar background (slightly darker)
  surfaceContainerHigh: Color(0xFFDFE3EC), // subtle contrast areas
  surfaceContainerHighest:
      Color(0xFFD7DDE7), // highest elevation (navbar, appbar bg)

  // === Outline & Shadows ===
  outline: Color(0xFF74777B),
  outlineVariant: Color(0xFFB9BCC1),
  shadow: Colors.black,
  scrim: Color(0x66000000),

  // === Inverse Colors ===
  inverseSurface: Color(0xFF2C2C2C),
  onInverseSurface: Colors.white,
  inversePrimary: Color(0xFF5E7CE2),
);

const ColorScheme blueDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,

  // === Primary ===
  primary: Color(0xFF6E8AF2),
  onPrimary: Colors.white,
  primaryContainer: Color(0xFF2F447A),
  onPrimaryContainer: Color(0xFFD6DEFF),

  // === Secondary (Cool Neutral Accent) ===
  secondary: Color(0xFFA4B8FF), // muted light desaturated blue-grey
  onSecondary: Color(0xFF101A33),
  secondaryContainer: Color(0xFF303E66),
  onSecondaryContainer: Color(0xFFD7E2FF),

  // === Tertiary ===
  tertiary: Color(0xFF6FB1FF),
  onTertiary: Color(0xFF081E2D),
  tertiaryContainer: Color(0xFF1E2B55),
  onTertiaryContainer: Color(0xFFD6E4FF),

  // === Error ===
  error: Color(0xFFF2B8B5),
  onError: Color(0xFF601410),
  errorContainer: Color(0xFF8C1D18),
  onErrorContainer: Color(0xFFF9DADA),

  // === Background & Surface ===
  background: Color(0xFF0E1115),
  onBackground: Color(0xFFE3E3E3),

  surface: Color(0xFF171A20),
  onSurface: Color(0xFFE3E3E3),

  surfaceVariant: Color(0xFF2C2F36),
  onSurfaceVariant: Color(0xFFC3C7CF),

  // === Surface Containers (Elevation tones) ===
  surfaceContainerLowest: Color(0xFF0E1013),
  surfaceContainerLow: Color(0xFF14161A),
  surfaceContainer: Color(0xFF1F242B),
  surfaceContainerHigh: Color(0xFF24272D),
  surfaceContainerHighest: Color(0xFF2C3240),

  // === Outline & Shadows ===
  outline: Color(0xFF8B8B8B),
  outlineVariant: Color(0xFF3C3F44),
  shadow: Colors.black,
  scrim: Color(0x99000000),

  // === Inverse Colors ===
  inverseSurface: Color(0xFFE3E3E3),
  onInverseSurface: Color(0xFF1A1C1E),
  inversePrimary: Color(0xFF92B4F4),
);

// =====================
// ==== GREEN TONES ====
// =====================
const ColorScheme greenLightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF1E8E3E), // Vibrant green
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFA8F5B1),
  onPrimaryContainer: Color(0xFF002108),

  secondary: Color(0xFF4C6353), // Muted green-grey tone
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFCFE9D5),
  onSecondaryContainer: Color(0xFF092012),

  tertiary: Color(0xFF38656A), // Greenish-teal accent
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFBCEBF0),
  onTertiaryContainer: Color(0xFF002022),

  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),

  background: Color(0xFFFBFDF8),
  onBackground: Color(0xFF191C1A),

  surface: Color(0xFFFBFDF8),
  onSurface: Color(0xFF191C1A),

  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFF3F5EF),
  surfaceContainer: Color(0xFFECEFE9),
  surfaceContainerHigh: Color(0xFFE6E9E3),
  surfaceContainerHighest: Color(0xFFDFE3DD),

  surfaceVariant: Color(0xFFDDE5DA),
  onSurfaceVariant: Color(0xFF414941),

  outline: Color(0xFF727970),
  outlineVariant: Color(0xFFC1C9BE),

  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),

  inverseSurface: Color(0xFF2E312E),
  onInverseSurface: Color(0xFFF0F1EC),
  inversePrimary: Color(0xFF8ED997),
);

const ColorScheme greenDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF8ED997),
  onPrimary: Color(0xFF003912),
  primaryContainer: Color(0xFF005320),
  onPrimaryContainer: Color(0xFFA8F5B1),
  secondary: Color(0xFFB3CCBA),
  onSecondary: Color(0xFF1F3526),
  secondaryContainer: Color(0xFF354B3C),
  onSecondaryContainer: Color(0xFFCFE9D5),
  tertiary: Color(0xFFA0CFD4),
  onTertiary: Color(0xFF00363A),
  tertiaryContainer: Color(0xFF1E4D52),
  onTertiaryContainer: Color(0xFFBCEBF0),
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFDAD6),
  background: Color(0xFF101510),
  onBackground: Color(0xFFE0E3DD),
  surface: Color(0xFF101510),
  onSurface: Color(0xFFE0E3DD),
  surfaceContainerLowest: Color(0xFF0B0F0B),
  surfaceContainerLow: Color(0xFF171C17),
  surfaceContainer: Color(0xFF1B201B),
  surfaceContainerHigh: Color(0xFF232823),
  surfaceContainerHighest: Color(0xFF2E332E),
  surfaceVariant: Color(0xFF414941),
  onSurfaceVariant: Color(0xFFC1C9BE),
  outline: Color(0xFF8B9389),
  outlineVariant: Color(0xFF414941),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFFE0E3DD),
  onInverseSurface: Color(0xFF2E332E),
  inversePrimary: Color(0xFF1E8E3E),
);
