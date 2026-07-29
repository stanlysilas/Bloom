import 'dart:async';
import 'package:flutter/material.dart';

class AuthGoogleButton extends StatefulWidget {
  final FutureOr<void> Function() onSubmit;
  final String message;
  final bool? useBorder;

  const AuthGoogleButton({
    super.key,
    required this.onSubmit,
    required this.message,
    this.useBorder = false,
  });

  @override
  State<AuthGoogleButton> createState() => _AuthGoogleButtonState();
}

class _AuthGoogleButtonState extends State<AuthGoogleButton> {
  bool isLoading = false;
  bool hover = false;
  bool pressed = false;

  Future<void> _handleOnSubmit() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      await widget.onSubmit();
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  double get _scale {
    if (pressed) return 0.93;
    if (hover) return 0.97;
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() {
        hover = false;
        pressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() {
          pressed = true;
          hover = true;
        }),
        onTapUp: (_) => setState(() {
          pressed = false;
          hover = false;
        }),
        onTapCancel: () => setState(() {
          pressed = false;
          hover = false;
        }),
        onTap: isLoading ? null : _handleOnSubmit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: AnimatedScale(
            scale: _scale,
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.primary),
                color: hover
                    ? colorScheme.primary.withAlpha(60)
                    : Colors.transparent,
              ),
              child: isLoading
                  ? CircularProgressIndicator(
                      year2023: false,
                      color: colorScheme.primary,
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/auth_images/google_logo.png',
                          scale: 42,
                        ),
                        const SizedBox(width: 14),
                        Text(
                          widget.message,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
