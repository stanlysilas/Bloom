import 'package:flutter/material.dart';

class ColorPaletteButton extends StatelessWidget {
  final List<Color> colors;
  final bool isSelected;
  final VoidCallback onTap;

  /// [ColorPaletteButton] is a [Row] of the [ColorScheme] button with the
  /// Primary, Secondary, and Tertiary [Colors] of the respective [ColorScheme]'s.
  const ColorPaletteButton({
    super.key,
    required this.colors,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      splashColor: Theme.of(context).colorScheme.primary.withAlpha(50),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(colors.length, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors[index],
              ),
            );
          }),
        ),
      ),
    );
  }
}
