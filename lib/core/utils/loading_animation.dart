import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class _BlobState {
  final double spawnX, spawnY;
  final double targetX, targetY;
  final double phase;
  final double lifetime;
  final double birthTime;
  final int colorIndex;
  final double radiusScale;

  const _BlobState({
    required this.spawnX,
    required this.spawnY,
    required this.targetX,
    required this.targetY,
    required this.phase,
    required this.lifetime,
    required this.birthTime,
    required this.colorIndex,
    required this.radiusScale,
  });
}

class BreathingLoader extends StatefulWidget {
  const BreathingLoader({super.key});

  @override
  State<BreathingLoader> createState() => _BreathingLoaderState();
}

class _BreathingLoaderState extends State<BreathingLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final math.Random _rng = math.Random();

  final List<_BlobState> _blobs = [];
  static const int _maxBlobs = 5;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )
      ..addListener(_tick)
      ..repeat();

    for (int i = 0; i < _maxBlobs; i++) {
      _blobs.add(_spawnBlob(birthTime: i / _maxBlobs));
    }
  }

  void _tick() {
    final now = _controller.value;

    _blobs.removeWhere((b) {
      final age = (now - b.birthTime + 1.0) % 1.0;
      return age > b.lifetime;
    });

    while (_blobs.length < _maxBlobs) {
      _blobs.add(_spawnBlob(birthTime: now));
    }
  }

  _BlobState _spawnBlob({required double birthTime}) {
    return _BlobState(
      spawnX: _rng.nextDouble(),
      spawnY: _rng.nextDouble(),
      targetX: (_rng.nextDouble() * 0.6 + 0.2).clamp(0.0, 1.0),
      targetY: (_rng.nextDouble() * 0.6 + 0.2).clamp(0.0, 1.0),
      phase: _rng.nextDouble() * math.pi * 2,
      lifetime: 0.5 + _rng.nextDouble() * 0.5,
      birthTime: birthTime,
      colorIndex: _rng.nextInt(4),
      radiusScale: 0.30 + _rng.nextDouble() * 0.45,
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_tick);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _MeshGradientPainter(
              t: _controller.value,
              blobs: List.unmodifiable(_blobs),
              primary: scheme.primary,
              secondary: scheme.secondary,
              tertiary: scheme.tertiary,
              isDark: isDark,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _MeshGradientPainter extends CustomPainter {
  final double t;
  final List<_BlobState> blobs;
  final Color primary, secondary, tertiary;
  final bool isDark;

  _MeshGradientPainter({
    required this.t,
    required this.blobs,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.isDark,
  });

  double _ease(double x) => x * x * (3 - 2 * x);

  Color _deepen(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness * (1 - amount)).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation * 1.2).clamp(0.0, 1.0))
        .toColor();
  }

  Color _bilerp(
      Color c00, Color c10, Color c01, Color c11, double u, double v) {
    return Color.lerp(Color.lerp(c00, c10, u)!, Color.lerp(c01, c11, u)!, v)!;
  }

  Color _blobColor(int index, double alpha) {
    final mix = Color.lerp(primary, tertiary, 0.5)!;
    final base = [primary, secondary, tertiary, mix][index];
    return base.withAlpha(alpha.round().clamp(0, 255));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final et = _ease(t);
    final rect = Offset.zero & size;

    final bgColor = isDark
        ? _deepen(primary, 0.88)
        : Color.lerp(primary, Colors.white, 0.82)!;
    canvas.drawRect(rect, Paint()..color = bgColor);

    final deepAmount = isDark ? 0.50 : 0.10;
    final p = _deepen(primary, deepAmount);
    final s = _deepen(secondary, deepAmount);
    final tr = _deepen(tertiary, deepAmount);

    double wave(double phase) =>
        _ease((math.sin(t * math.pi * 2 + phase) + 1) / 2);

    final c00 = Color.lerp(p, s, wave(0.0))!;
    final c10 = Color.lerp(s, tr, wave(math.pi * 0.66))!;
    final c01 = Color.lerp(tr, p, wave(math.pi * 1.33))!;
    final c11 =
        Color.lerp(Color.lerp(p, tr, 0.5)!, Color.lerp(s, p, 0.5)!, et)!;

    const steps = 64;
    final cellW = w / steps;
    final cellH = h / steps;
    final meshPaint = Paint();
    for (int row = 0; row < steps; row++) {
      for (int col = 0; col < steps; col++) {
        meshPaint.color = _bilerp(
            c00, c10, c01, c11, (col + 0.5) / steps, (row + 0.5) / steps);
        canvas.drawRect(
          Rect.fromLTWH(col * cellW, row * cellH, cellW + 0.6, cellH + 0.6),
          meshPaint,
        );
      }
    }

    for (final blob in blobs) {
      final age = ((t - blob.birthTime + 1.0) % 1.0) / blob.lifetime;

      final double opacity;
      if (age < 0.20) {
        opacity = _ease(age / 0.20);
      } else if (age < 0.80) {
        opacity = 1.0;
      } else {
        opacity = _ease(1.0 - (age - 0.80) / 0.20);
      }

      final cx = (blob.spawnX + (blob.targetX - blob.spawnX) * age) * w;
      final cy = (blob.spawnY + (blob.targetY - blob.spawnY) * age) * h;

      final breathe = 0.6 + 0.4 * math.sin(t * math.pi * 2 + blob.phase);
      final radius = w * blob.radiusScale * breathe;

      final baseAlpha = isDark ? 190.0 : 140.0;
      final color = _blobColor(blob.colorIndex, baseAlpha * opacity);
      final center = Offset(cx, cy);

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = ui.Gradient.radial(
            center,
            radius,
            [color, color.withAlpha(0)],
            [0.0, 1.0],
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 52),
      );
    }
  }

  @override
  bool shouldRepaint(_MeshGradientPainter old) => true;
}
