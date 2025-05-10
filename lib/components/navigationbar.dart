import 'dart:io';

import 'package:bloom/screens/dashboard_screen.dart';
import 'package:bloom/screens/entries_screen.dart';
// import 'package:bloom/screens/pomodoro_timer.dart';
import 'package:bloom/screens/eventsandschedules_screen.dart';
import 'package:bloom/screens/moreoptions_screen.dart';
import 'package:bloom/screens/tasksandhabits_screen.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

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
    const TaskScreen(),
    const SchedulesScreen(),
    const EntriesScreen(),
    const MoreOptionsScreen(),
    // const PomodoroTimer(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentPageIndex],
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        indicatorColor: Theme.of(context).primaryColor,
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Iconsax.home,
            ),
            label: 'Home',
            tooltip: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Iconsax.task_square4,
            ),
            label: 'Goals',
            tooltip: 'Goals',
          ),
          NavigationDestination(
            icon: Icon(
              Iconsax.calendar_1,
            ),
            label: 'Schedules',
            tooltip: 'Schedules',
          ),
          NavigationDestination(
            icon: Icon(
              Iconsax.book,
            ),
            label: 'Entries',
            tooltip: 'Entries',
          ),
          NavigationDestination(
            icon: Icon(
              Iconsax.more,
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
