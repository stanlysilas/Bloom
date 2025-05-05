import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NavigationView(
            pane: NavigationPane(items: [
              PaneItem(
                  icon: const Icon(FluentIcons.accept),
                  body: const Text('data')),
              PaneItem(
                  icon: const Icon(FluentIcons.accept),
                  body: const Text('data')),
              PaneItem(
                  icon: const Icon(FluentIcons.accept),
                  body: const Text('data'))
            ]),
            content: Container(
              padding: const EdgeInsets.all(12),
              child: const Text('Fluent_UI Widgets test'),
            ),
          )
        ],
      )),
    );
  }
}
