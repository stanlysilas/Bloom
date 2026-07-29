import 'package:bloom/core/widgets/bloom_sidebar.dart';
import 'package:bloom/features/calendar/calendar_screen.dart';
import 'package:bloom/features/home/dashboard_screen.dart';
import 'package:bloom/features/objects/screens/objects_screen.dart';
import 'package:bloom/features/goals/goals_screen.dart';
import 'package:bloom/features/settings/screens/settings_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Navigationrail extends StatefulWidget {
  const Navigationrail({super.key});

  @override
  State<Navigationrail> createState() => _NavigationrailState();
}

class _NavigationrailState extends State<Navigationrail> {
  int _currentPageIndex = 0;

  late final List<Widget> _screens = [
    DashboardScreen(isAndroid: defaultTargetPlatform == TargetPlatform.android),
    const GoalsScreen(),
    const EntriesScreen(),
    CalendarViewScreen(initialDay: DateTime.now()),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BloomSidebar(
            onItemSelected: (int index) =>
                setState(() => _currentPageIndex = index),
            selectedIndex: _currentPageIndex,
          ),
          Expanded(
            child: IndexedStack(
              index: _currentPageIndex,
              children: _screens,
            ),
          ),
        ],
      ),
    );
  }
}
