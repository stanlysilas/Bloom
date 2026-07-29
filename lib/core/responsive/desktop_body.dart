import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:bloom/core/widgets/navigationrail.dart';
import 'package:flutter/material.dart';

class DesktopBody extends StatefulWidget {
  const DesktopBody({super.key});

  @override
  State<DesktopBody> createState() => _DesktopBodyState();
}

class _DesktopBodyState extends State<DesktopBody> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WindowBorder(
      color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
      child: Scaffold(
        body: const Navigationrail(),
      ),
    );
  }
}
