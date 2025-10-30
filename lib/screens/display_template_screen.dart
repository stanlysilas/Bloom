import 'package:flutter/material.dart';

class DisplayTemplateScreen extends StatefulWidget {
  final String templateTitle;
  final String templateDescription;
  const DisplayTemplateScreen(
      {super.key,
      required this.templateTitle,
      required this.templateDescription});

  @override
  State<DisplayTemplateScreen> createState() => _DisplayTemplateScreenState();
}

class _DisplayTemplateScreenState extends State<DisplayTemplateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.templateTitle,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
