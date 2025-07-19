import 'dart:io';

import 'package:bloom/screens/dashboard_screen.dart';
import 'package:bloom/screens/entries_screen.dart';
// import 'package:bloom/screens/pomodoro_timer.dart';
import 'package:bloom/screens/moreoptions_screen.dart';
import 'package:bloom/screens/goals_screen.dart';
import 'package:flutter/material.dart';

class Navigationbar extends StatefulWidget {
  const Navigationbar({
    super.key,
  });

  @override
  State<Navigationbar> createState() => _NavigationbarState();
}

class _NavigationbarState extends State<Navigationbar> {
  int currentPageIndex = 0;
  final screens = [
    DashboardScreen(isAndroid: Platform.isAndroid),
    const GoalsScreen(),
    const EntriesScreen(),
    const MoreOptionsScreen(),
    // const PomodoroTimer(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentPageIndex],
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: Theme.of(context).primaryColor,
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_rounded,
            ),
            label: 'Home',
            tooltip: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.task_rounded,
            ),
            label: 'Goals',
            tooltip: 'Goals',
          ),
          // NavigationDestination(
          //   icon: Icon(
          //     Icons.calendar_month_rounded,
          //   ),
          //   label: 'Schedules',
          //   tooltip: 'Schedules',
          // ),
          NavigationDestination(
            icon: Icon(
              Icons.book_rounded,
            ),
            label: 'Entries',
            tooltip: 'Entries',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.more_horiz_rounded,
            ),
            label: 'More',
            tooltip: 'More',
          ),
        ],
        selectedIndex: currentPageIndex,
        onDestinationSelected: (currentPageIndex) =>
            setState(() => this.currentPageIndex = currentPageIndex),
      ),
    );
  }
}
