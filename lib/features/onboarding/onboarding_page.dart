import 'package:flutter/material.dart';

class OnboardingPageData {
  final String title;
  final String? highlightedTitle;
  final String description;
  final String imageAsset;
  final String imageSemanticLabel;
  final String? footnote;

  const OnboardingPageData({
    required this.title,
    this.highlightedTitle,
    required this.description,
    required this.imageAsset,
    required this.imageSemanticLabel,
    this.footnote,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;
  final Widget? footer;

  const OnboardingPage({
    super.key,
    required this.data,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      header: true,
      label: data.title,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              data.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            if (data.highlightedTitle != null) ...[
              const SizedBox(height: 4),
              Text(
                data.highlightedTitle!,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              data.description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            if (data.footnote != null) ...[
              const SizedBox(height: 12),
              Text(
                data.footnote!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (footer != null) ...[
              const SizedBox(height: 20),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}
