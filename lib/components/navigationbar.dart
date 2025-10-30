import 'package:bloom/components/bloom_buttons.dart';
import 'package:bloom/screens/custom_templates_screen.dart';
import 'package:bloom/screens/dashboard_screen.dart';
import 'package:bloom/screens/entries_screen.dart';
import 'package:bloom/screens/moreoptions_screen.dart';
import 'package:bloom/screens/goals_screen.dart';
import 'package:flutter/foundation.dart';
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
    DashboardScreen(
        isAndroid:
            defaultTargetPlatform == TargetPlatform.android ? true : false),
    const GoalsScreen(),
    const EntriesScreen(),
    const MoreOptionsScreen(),
    // const PomodoroTimer(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: screens[currentPageIndex],
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        onPressed: () {
          if (currentPageIndex == 0) {
            // All objects adding sheet
            showObjectsModalBottomSheet(context);
          } else if (currentPageIndex == 1) {
            // Add new goal process
            showModalBottomSheet(
                context: context,
                showDragHandle: true,
                enableDrag: true,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (context) => GoalObjectsModalSheet());
          } else if (currentPageIndex == 2) {
            showModalBottomSheet(
              context: context,
              showDragHandle: true,
              enableDrag: true,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (context) {
                return SafeArea(
                  child: Column(
                    children: [
                      // Display all the basic objects
                      const Expanded(
                        child: TypesOfEntries(),
                      ),
                      // Display a button to more templates
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'More entry ',
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      const CustomTemplatesScreen()));
                            },
                            child: Row(
                              children: [
                                Text(
                                  'templates',
                                  style: TextStyle(
                                      decorationColor:
                                          Theme.of(context).colorScheme.primary,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.bold),
                                ),
                                Icon(
                                  Icons.open_in_new_rounded,
                                  size: 14,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8)
                    ],
                  ),
                );
              },
            );
          } else if (currentPageIndex == 3) {
            // All objects adding sheet
            showObjectsModalBottomSheet(context);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
