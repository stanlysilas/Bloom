import 'package:bloom/theme/colors.dart';
import 'package:bloom/theme/color_palette_button.dart';
import 'package:bloom/theme/color_scheme_provider.dart';
import 'package:bloom/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ColorPickerPanel extends StatelessWidget {
  const ColorPickerPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final colorProvider = Provider.of<ColorSchemeProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isLight = colorProvider.currentScheme.brightness == Brightness.light;

    final colorFamilies = [
      {
        'colors': isLight
            ? [
                blueLightColorScheme.primary,
                blueLightColorScheme.secondary,
                blueLightColorScheme.tertiary,
              ]
            : [
                blueDarkColorScheme.primary,
                blueDarkColorScheme.secondary,
                blueDarkColorScheme.tertiary,
              ],
        'name': 'Default Blue',
      },
      {
        'colors': isLight
            ? [
                greenLightColorScheme.primary,
                greenLightColorScheme.secondary,
                greenLightColorScheme.tertiary,
              ]
            : [
                greenDarkColorScheme.primary,
                greenDarkColorScheme.secondary,
                greenDarkColorScheme.tertiary,
              ],
        'name': 'Nature Green',
      },
      {
        'colors': isLight
            ? [
                amberLightColorScheme.primary,
                amberLightColorScheme.secondary,
                amberLightColorScheme.tertiary,
              ]
            : [
                amberDarkColorScheme.primary,
                amberDarkColorScheme.secondary,
                amberDarkColorScheme.tertiary,
              ],
        'name': 'Momentum Amber',
      },
      {
        'colors': isLight
            ? [
                crimsonLightColorScheme.primary,
                crimsonLightColorScheme.secondary,
                crimsonLightColorScheme.tertiary,
              ]
            : [
                crimsonDarkColorScheme.primary,
                crimsonDarkColorScheme.secondary,
                crimsonDarkColorScheme.tertiary,
              ],
        'name': 'Crimson Serenity',
      },
      {
        'colors': isLight
            ? [
                obsidianLightColorScheme.primary,
                obsidianLightColorScheme.secondary,
                obsidianLightColorScheme.tertiary,
              ]
            : [
                obsidianDarkColorScheme.primary,
                obsidianDarkColorScheme.secondary,
                obsidianDarkColorScheme.tertiary,
              ],
        'name': 'Obsidian Focus',
      },
      {
        'colors': isLight
            ? [
                purpleLightColorScheme.primary,
                purpleLightColorScheme.secondary,
                purpleLightColorScheme.tertiary,
              ]
            : [
                purpleDarkColorScheme.primary,
                purpleDarkColorScheme.secondary,
                purpleDarkColorScheme.tertiary,
              ],
        'name': 'Lavender Muse',
      },
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.spaceEvenly,
      children: List.generate(colorFamilies.length, (index) {
        final family = colorFamilies[index];
        final colors = family['colors'] as List<Color>;
        final name = family['name'] as String;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorPaletteButton(
              colors: colors,
              isSelected: colorProvider.selectedSchemeIndex == index,
              onTap: () {
                colorProvider.setColorScheme(index);
                themeProvider.setAccent(index);
              },
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 100,
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  overflow: TextOverflow.clip,
                  fontSize:
                      colorProvider.selectedSchemeIndex == index ? 14 : 13,
                  fontWeight: colorProvider.selectedSchemeIndex == index
                      ? FontWeight.bold
                      : null,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
