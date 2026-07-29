import 'dart:async';
import 'package:flutter/material.dart';

class AuthSubmitButton extends StatefulWidget {
  final FutureOr<void> Function() onSubmit;
  final String message;
  final bool? useBorder;

  const AuthSubmitButton({
    super.key,
    required this.onSubmit,
    required this.message,
    this.useBorder = false,
  });

  @override
  State<AuthSubmitButton> createState() => _AuthSubmitButtonState();
}

class _AuthSubmitButtonState extends State<AuthSubmitButton> {
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
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              width: double.infinity,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
                border: widget.useBorder == true
                    ? Border.all(color: colorScheme.primary)
                    : null,
                boxShadow: hover
                    ? [
                        BoxShadow(
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                          color: colorScheme.primary.withAlpha(50),
                        ),
                        BoxShadow(
                          blurRadius: 18,
                          offset: const Offset(0, -6),
                          color: colorScheme.primary.withAlpha(50),
                        )
                      ]
                    : [],
              ),
              child: isLoading
                  ? CircularProgressIndicator(
                      year2023: false,
                      color: colorScheme.onPrimary,
                    )
                  : Text(
                      widget.message,
                      style: const TextStyle(fontSize: 18),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
