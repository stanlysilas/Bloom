import 'package:flutter/material.dart';

class PrivacyPasswordScreen extends StatefulWidget {
  const PrivacyPasswordScreen({super.key});

  @override
  State<PrivacyPasswordScreen> createState() => _PrivacyPasswordScreenState();
}

class _PrivacyPasswordScreenState extends State<PrivacyPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Password'),
      ),
    );
  }
}
