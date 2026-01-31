import 'package:flutter/material.dart';

class BreathingLoader extends StatefulWidget {
  const BreathingLoader({super.key});

  @override
  State<BreathingLoader> createState() => _BreathingLoaderState();
}

class _BreathingLoaderState extends State<BreathingLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            final scale = 0.6 + (_controller.value * 0.5);
            final opacity = 0.3 + (_controller.value * 0.7);
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withAlpha((opacity * 0.6).toInt()),
                  boxShadow: [
                    BoxShadow(
                      color: color.withAlpha(40),
                      blurRadius: 40 * _controller.value,
                      spreadRadius: 8 * _controller.value,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withAlpha(80),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
