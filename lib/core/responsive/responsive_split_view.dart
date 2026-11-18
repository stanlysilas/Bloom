import 'package:bloom/core/responsive/dimensions.dart';
import 'package:flutter/material.dart';

class ResponsiveSplitView extends StatelessWidget {
  final Widget visual;
  final Widget content;
  final double breakpoint;
  final double maxContentWidth;
  final double maxVisualWidth;
  final EdgeInsetsGeometry padding;
  final double gap;

  const ResponsiveSplitView({
    super.key,
    required this.visual,
    required this.content,
    this.breakpoint = mobileWidth,
    this.maxContentWidth = 600,
    this.maxVisualWidth = 700,
    this.padding = const EdgeInsets.all(32),
    this.gap = 48,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= breakpoint;

    if (!isWide) {
      return SingleChildScrollView(
        padding: padding,
        child: Column(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxVisualWidth,
              ),
              child: visual,
            ),
            const SizedBox(height: 32),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxContentWidth,
              ),
              child: content,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Row(
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxVisualWidth,
                ),
                child: visual,
              ),
            ),
          ),
          SizedBox(width: gap),
          Flexible(
            fit: FlexFit.loose,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxContentWidth,
                ),
                child: content,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
