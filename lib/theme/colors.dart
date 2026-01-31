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

// ======================
// ==== YELLOW TONES ====
// ======================
const ColorScheme amberLightColorScheme = ColorScheme(
  brightness: Brightness.light,

  // === Primary ===
  primary: Color(0xFFFFB300), // vivid amber
  onPrimary: Colors.white,
  primaryContainer: Color(0xFFFFE082),
  onPrimaryContainer: Color(0xFF3B2A00),

  // === Secondary ===
  secondary: Color(0xFF8C6D1F),
  onSecondary: Colors.white,
  secondaryContainer: Color(0xFFFFE4A8), // slightly darker for better contrast
  onSecondaryContainer: Color(0xFF2C1F00),

  // === Tertiary ===
  tertiary: Color(0xFFC58A35),
  onTertiary: Colors.white,
  tertiaryContainer: Color(0xFFFFDCA9),
  onTertiaryContainer: Color(0xFF3A2600),

  // === Error ===
  error: Color(0xFFBA1A1A),
  onError: Colors.white,
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),

  // === Background & Surface ===
  background: Color(0xFFFFFBF7),
  onBackground: Color(0xFF1C1B17),

  surface: Color(0xFFFFFBF7),
  onSurface: Color(0xFF1C1B17),

  surfaceVariant: Color(0xFFF0E0C8),
  onSurfaceVariant: Color(0xFF504534),

  // === Surface Containers (elevation tones) ===
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFFFF6E9),
  surfaceContainer: Color(0xFFFDEFD8),
  surfaceContainerHigh: Color(0xFFF6E8C9),
  surfaceContainerHighest: Color(0xFFEFDEB7),

  // === Outline & Shadows ===
  outline: Color(0xFF83755F),
  outlineVariant: Color(0xFFD9C7A9),
  shadow: Colors.black,
  scrim: Color(0x66000000),

  // === Inverse Colors ===
  inverseSurface: Color(0xFF322F2B),
  onInverseSurface: Color(0xFFFBE9D5),
  inversePrimary: Color(0xFFFFCB47),
);

const ColorScheme amberDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,

  // === Primary ===
  primary: Color(0xFFFFC640), // brighter amber pop
  onPrimary: Color(0xFF2E1B00),
  primaryContainer: Color(0xFF6C4B00),
  onPrimaryContainer: Color(0xFFFFE6B3),

  // === Secondary ===
  secondary: Color(0xFFE6B25C),
  onSecondary: Color(0xFF2A1800),
  secondaryContainer: Color(0xFF5A3B00),
  onSecondaryContainer: Color(0xFFFFE0B3),

  // === Tertiary ===
  tertiary: Color(0xFFFFB84D),
  onTertiary: Color(0xFF332000),
  tertiaryContainer: Color(0xFF7A4E00),
  onTertiaryContainer: Color(0xFFFFE8CC),

  // === Error ===
  error: Color(0xFFF2B8B5),
  onError: Color(0xFF601410),
  errorContainer: Color(0xFF8C1D18),
  onErrorContainer: Color(0xFFF9DADA),

  // === Background & Surface (cool-neutral base for better contrast) ===
  background: Color(0xFF1B1B1C), // neutral dark grey, not brown
  onBackground: Color(0xFFECE6DF),

  surface: Color(0xFF1B1B1C),
  onSurface: Color(0xFFECE6DF),

  surfaceVariant: Color(0xFF3E3A35),
  onSurfaceVariant: Color(0xFFD5C6B8),

  // === Surface Containers (for elevation depth) ===
  surfaceContainerLowest: Color(0xFF121212),
  surfaceContainerLow: Color(0xFF181818),
  surfaceContainer: Color(0xFF202020),
  surfaceContainerHigh: Color(0xFF262422),
  surfaceContainerHighest: Color(0xFF2E2B27),

  // === Outline & Shadows ===
  outline: Color(0xFF9E8E75),
  outlineVariant: Color(0xFF3F352C),
  shadow: Colors.black,
  scrim: Color(0x99000000),

  // === Inverse Colors ===
  inverseSurface: Color(0xFFF8F6F3),
  onInverseSurface: Color(0xFF26231F),
  inversePrimary: Color(0xFFFFB74D),
);

// ==========================
// ==== RED/MAROON TONES ====
// ==========================
const ColorScheme crimsonLightColorScheme = ColorScheme(
  brightness: Brightness.light,

  // === Primary (Core love tone) ===
  primary: Color(0xFFD46A6A), // soft crimson red
  onPrimary: Colors.white,
  primaryContainer: Color(0xFFFFD8D8), // gentle blush background
  onPrimaryContainer: Color(0xFF400010),

  // === Secondary (Muted complementary) ===
  secondary: Color(0xFF996A6A), // desaturated rose-brown
  onSecondary: Colors.white,
  secondaryContainer: Color(0xFFF1D5D5), // dusty pink container
  onSecondaryContainer: Color(0xFF2B0E0E),

  // === Tertiary (Supportive accent, warm beige) ===
  tertiary: Color(0xFFB98A7A),
  onTertiary: Colors.white,
  tertiaryContainer: Color(0xFFFFE1D5),
  onTertiaryContainer: Color(0xFF331007),

  // === Error ===
  error: Color(0xFFBA1A1A),
  onError: Colors.white,
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),

  // === Background & Surface ===
  background: Color(0xFFFFFBFA),
  onBackground: Color(0xFF1C1B1B),

  surface: Color(0xFFFFFBFA),
  onSurface: Color(0xFF1C1B1B),

  surfaceVariant: Color(0xFFF3DDDC),
  onSurfaceVariant: Color(0xFF524343),

  // === Surface Containers ===
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFFFF7F6),
  surfaceContainer: Color(0xFFFEEDEC),
  surfaceContainerHigh: Color(0xFFF6E3E2),
  surfaceContainerHighest: Color(0xFFEED8D7),

  // === Outline & Shadows ===
  outline: Color(0xFF857373),
  outlineVariant: Color(0xFFD8C2C1),
  shadow: Colors.black,
  scrim: Color(0x66000000),

  // === Inverse Colors ===
  inverseSurface: Color(0xFF322F2F),
  onInverseSurface: Color(0xFFFBEDEC),
  inversePrimary: Color(0xFFFFB3B3),
);

const ColorScheme crimsonDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,

  // === Primary ===
  primary: Color(0xFFFFB3B3),
  onPrimary: Color(0xFF5C0A0A),
  primaryContainer: Color(0xFF7A2E2E),
  onPrimaryContainer: Color(0xFFFFDADA),

  // === Secondary ===
  secondary: Color(0xFFE0B3B3),
  onSecondary: Color(0xFF421A1A),
  secondaryContainer: Color(0xFF5E3434),
  onSecondaryContainer: Color(0xFFF9DADA),

  // === Tertiary ===
  tertiary: Color(0xFFE5B7A9),
  onTertiary: Color(0xFF4C261C),
  tertiaryContainer: Color(0xFF663C30),
  onTertiaryContainer: Color(0xFFFFDAD0),

  // === Error ===
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFDAD6),

  // === Background & Surface ===
  background: Color(0xFF1C1B1B),
  onBackground: Color(0xFFEDE0DF),

  surface: Color(0xFF1C1B1B),
  onSurface: Color(0xFFEDE0DF),

  surfaceVariant: Color(0xFF524343),
  onSurfaceVariant: Color(0xFFD8C2C1),

  // === Surface Containers ===
  surfaceContainerLowest: Color(0xFF141212),
  surfaceContainerLow: Color(0xFF1D1B1B),
  surfaceContainer: Color(0xFF2B2424),
  surfaceContainerHigh: Color(0xFF372D2C),
  surfaceContainerHighest: Color(0xFF433534),

  // === Outline & Shadows ===
  outline: Color(0xFFA08C8B),
  outlineVariant: Color(0xFF524343),
  shadow: Colors.black,
  scrim: Color(0x99000000),

  // === Inverse Colors ===
  inverseSurface: Color(0xFFEDE0DF),
  onInverseSurface: Color(0xFF1C1B1B),
  inversePrimary: Color(0xFFD46A6A),
);

// ==========================
// ==== MONOCHROME TONES ====
// ==========================
const ColorScheme obsidianLightColorScheme = ColorScheme(
  brightness: Brightness.light,

  // === Primary (Core grey tone) ===
  primary: Color(0xFF4A4A4A),
  onPrimary: Colors.white,
  primaryContainer: Color(0xFFD9D9D9),
  onPrimaryContainer: Color(0xFF121212),

  // === Secondary (Neutral subtle contrast) ===
  secondary: Color(0xFF6C6C6C),
  onSecondary: Colors.white,
  secondaryContainer: Color(0xFFE3E3E3),
  onSecondaryContainer: Color(0xFF1C1C1C),

  // === Tertiary (Cool light grey accent) ===
  tertiary: Color(0xFF9A9A9A),
  onTertiary: Colors.black,
  tertiaryContainer: Color(0xFFF0F0F0),
  onTertiaryContainer: Color(0xFF1A1A1A),

  // === Error ===
  error: Color(0xFFB00020),
  onError: Colors.white,
  errorContainer: Color(0xFFFCDADA),
  onErrorContainer: Color(0xFF410002),

  // === Background & Surface ===
  background: Color(0xFFFAFAFA),
  onBackground: Color(0xFF1A1A1A),

  surface: Color(0xFFFFFFFF),
  onSurface: Color(0xFF1A1A1A),

  surfaceVariant: Color(0xFFE0E0E0),
  onSurfaceVariant: Color(0xFF4F4F4F),

  // === Surface Containers ===
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFF5F5F5),
  surfaceContainer: Color(0xFFEEEEEE),
  surfaceContainerHigh: Color(0xFFE8E8E8),
  surfaceContainerHighest: Color(0xFFE0E0E0),

  // === Outline & Shadows ===
  outline: Color(0xFF8A8A8A),
  outlineVariant: Color(0xFFBDBDBD),
  shadow: Colors.black,
  scrim: Color(0x66000000),

  // === Inverse Colors ===
  inverseSurface: Color(0xFF2A2A2A),
  onInverseSurface: Color(0xFFECECEC),
  inversePrimary: Color(0xFF808080),
);

const ColorScheme obsidianDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,

  // === Primary ===
  primary: Color(0xFFCCCCCC),
  onPrimary: Color(0xFF1A1A1A),
  primaryContainer: Color(0xFF2A2A2A),
  onPrimaryContainer: Color(0xFFE5E5E5),

  // === Secondary ===
  secondary: Color(0xFFB3B3B3),
  onSecondary: Color(0xFF202020),
  secondaryContainer: Color(0xFF383838),
  onSecondaryContainer: Color(0xFFE0E0E0),

  // === Tertiary ===
  tertiary: Color(0xFFA8A8A8),
  onTertiary: Color(0xFF202020),
  tertiaryContainer: Color(0xFF444444),
  onTertiaryContainer: Color(0xFFE2E2E2),

  // === Error ===
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFDAD6),

  // === Background & Surface ===
  background: Color(0xFF121212),
  onBackground: Color(0xFFE0E0E0),

  surface: Color(0xFF181818),
  onSurface: Color(0xFFE0E0E0),

  surfaceVariant: Color(0xFF2C2C2C),
  onSurfaceVariant: Color(0xFFB3B3B3),

  // === Surface Containers ===
  surfaceContainerLowest: Color(0xFF0D0D0D),
  surfaceContainerLow: Color(0xFF1A1A1A),
  surfaceContainer: Color(0xFF222222),
  surfaceContainerHigh: Color(0xFF2B2B2B),
  surfaceContainerHighest: Color(0xFF343434),

  // === Outline & Shadows ===
  outline: Color(0xFF8C8C8C),
  outlineVariant: Color(0xFF3F3F3F),
  shadow: Colors.black,
  scrim: Color(0x99000000),

  // === Inverse Colors ===
  inverseSurface: Color(0xFFECECEC),
  onInverseSurface: Color(0xFF1A1A1A),
  inversePrimary: Color(0xFF9E9E9E),
);

// ======================
// ==== PURPLE TONES ====
// ======================
const ColorScheme purpleLightColorScheme = ColorScheme(
  brightness: Brightness.light,

  // === Primary (Brand color) ===
  primary: Color(0xFF9B8AFB), // soft violet-purple
  onPrimary: Colors.white,
  primaryContainer: Color(0xFFE6DDFF),
  onPrimaryContainer: Color(0xFF1E0053),

  // === Secondary (Accents & icons) ===
  secondary: Color(0xFF8C7DD6),
  onSecondary: Colors.white,
  secondaryContainer: Color(0xFFE2DCFA),
  onSecondaryContainer: Color(0xFF20104C),

  // === Tertiary (Subtle contrast tone) ===
  tertiary: Color(0xFFB88DD9),
  onTertiary: Colors.white,
  tertiaryContainer: Color(0xFFF0DBFB),
  onTertiaryContainer: Color(0xFF3A0E5A),

  // === Error ===
  error: Color(0xFFD32F2F),
  onError: Colors.white,
  errorContainer: Color(0xFFF9DADA),
  onErrorContainer: Color(0xFF690006),

  // === Background & Surface ===
  background: Color(0xFFF9F8FF),
  onBackground: Color(0xFF1B1A1E),

  surface: Color(0xFFF9F8FF),
  onSurface: Color(0xFF1B1A1E),

  surfaceVariant: Color(0xFFE4DEF2),
  onSurfaceVariant: Color(0xFF484652),

  // === Surface Containers (Elevation tones) ===
  surfaceContainerLowest: Color(0xFFFCFAFF),
  surfaceContainerLow: Color(0xFFF4F1FB),
  surfaceContainer: Color(0xFFE8E3F6),
  surfaceContainerHigh: Color(0xFFE0DAF2),
  surfaceContainerHighest: Color(0xFFD9D2EF),

  // === Outline & Shadows ===
  outline: Color(0xFF7A768B),
  outlineVariant: Color(0xFFBFBACF),
  shadow: Colors.black,
  scrim: Color(0x66000000),

  // === Inverse Colors ===
  inverseSurface: Color(0xFF2C2C34),
  onInverseSurface: Colors.white,
  inversePrimary: Color(0xFFBBA9FF),
);

const ColorScheme purpleDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,

  // === Primary (Brand color) ===
  primary: Color(0xFFBBA9FF),
  onPrimary: Color(0xFF2E0073),
  primaryContainer: Color(0xFF4C288A),
  onPrimaryContainer: Color(0xFFE6DDFF),

  // === Secondary (Accents & icons) ===
  secondary: Color(0xFFC5B9F8),
  onSecondary: Color(0xFF2E2167),
  secondaryContainer: Color(0xFF4A3A90),
  onSecondaryContainer: Color(0xFFE2DCFA),

  // === Tertiary (Subtle highlight) ===
  tertiary: Color(0xFFE3BBF7),
  onTertiary: Color(0xFF4A166A),
  tertiaryContainer: Color(0xFF652C8E),
  onTertiaryContainer: Color(0xFFF0DBFB),

  // === Error ===
  error: Color(0xFFF2B8B5),
  onError: Color(0xFF601410),
  errorContainer: Color(0xFF8C1D18),
  onErrorContainer: Color(0xFFF9DADA),

  // === Background & Surface ===
  background: Color(0xFF12101A),
  onBackground: Color(0xFFE7E0F6),

  surface: Color(0xFF1A1623),
  onSurface: Color(0xFFE7E0F6),

  surfaceVariant: Color(0xFF484652),
  onSurfaceVariant: Color(0xFFCAC4D8),

  // === Surface Containers (Elevation tones) ===
  surfaceContainerLowest: Color(0xFF0D0A12),
  surfaceContainerLow: Color(0xFF1A1623),
  surfaceContainer: Color(0xFF231E2C),
  surfaceContainerHigh: Color(0xFF2E2838),
  surfaceContainerHighest: Color(0xFF3A3347),

  // === Outline & Shadows ===
  outline: Color(0xFF928FA2),
  outlineVariant: Color(0xFF615E71),
  shadow: Colors.black,
  scrim: Color(0x66000000),

  // === Inverse Colors ===
  inverseSurface: Color(0xFFF4EFFB),
  onInverseSurface: Color(0xFF1E1926),
  inversePrimary: Color(0xFF7C63EA),
);
