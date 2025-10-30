import 'package:flutter/material.dart';

class ColorPaletteButton extends StatelessWidget {
  final List<Color> colors;
  final bool isSelected;
  final VoidCallback onTap;

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

// This is the new version, but needs a lot of working to perfect.
// import 'package:flutter/material.dart';
// import 'dart:math' as math;

// class ColorPaletteButton extends StatelessWidget {
//   final Color primary;
//   final Color secondary;
//   final Color tertiary;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const ColorPaletteButton({
//     super.key,
//     required this.primary,
//     required this.secondary,
//     required this.tertiary,
//     this.isSelected = false,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final borderColor =
//         isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent;

//     return InkWell(
//       onTap: onTap,
//       customBorder: const CircleBorder(),
//       splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
//       child: Container(
//         padding: const EdgeInsets.all(4),
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           border: Border.all(color: borderColor, width: 3),
//         ),
//         child: CustomPaint(
//           size: const Size(50, 50),
//           painter: _ColorPalettePainter(
//             primary: primary,
//             secondary: secondary,
//             tertiary: tertiary,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _ColorPalettePainter extends CustomPainter {
//   final Color primary;
//   final Color secondary;
//   final Color tertiary;

//   _ColorPalettePainter({
//     required this.primary,
//     required this.secondary,
//     required this.tertiary,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..style = PaintingStyle.fill;
//     final rect = Rect.fromLTWH(0, 0, size.width, size.height);
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = size.width / 2;

//     // Top half – Primary
//     paint.color = primary;
//     canvas.drawArc(rect, -math.pi / 2, math.pi, true, paint);

//     // Bottom-left – Secondary
//     paint.color = secondary;
//     canvas.drawArc(rect, math.pi / 2, math.pi / 2, true, paint);

//     // Bottom-right – Tertiary
//     paint.color = tertiary;
//     canvas.drawArc(rect, 0, math.pi / 2, true, paint);

//     // Optional: subtle outline to match Pixel UI
//     final stroke = Paint()
//       ..color = Colors.black.withOpacity(0.05)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.5;
//     canvas.drawCircle(center, radius, stroke);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
