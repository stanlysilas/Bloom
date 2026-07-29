import 'package:flutter/material.dart';

class ActionFormLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final String buttonText;
  final VoidCallback onSubmit;

  const ActionFormLayout({
    super.key,
    required this.child,
    required this.title,
    required this.buttonText,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: child),
            Padding(
              padding: const EdgeInsets.all(16),
              child: InkWell(
                onTap: onSubmit,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: Center(
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
