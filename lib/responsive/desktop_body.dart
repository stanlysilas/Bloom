import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:bloom/responsive/dimensions.dart';
import 'package:bloom/windows_components/navigationrail.dart';
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
        body: Row(
          children: [
            SizedBox(
              width: sideBarSize,
              child: const Navigationrail(),
            ),
          ],
        ),
      ),
    );
  }
}
