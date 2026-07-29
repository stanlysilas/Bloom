import 'package:bloom/core/widgets/bloom_buttons.dart';
import 'package:bloom/features/home/dashboard_screen.dart';
import 'package:bloom/features/objects/screens/objects_screen.dart';
import 'package:bloom/features/home/screens/moreoptions_screen.dart';
import 'package:bloom/features/goals/goals_screen.dart';
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
    const MoreOptionsScreen()
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
        maintainBottomViewPadding: false,
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
            showObjectsModalBottomSheet(context);
          } else if (currentPageIndex == 1) {
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
                      const Expanded(
                        child: TypesOfEntries(),
                      ),
                      const SizedBox(height: 8)
                    ],
                  ),
                );
              },
            );
          } else if (currentPageIndex == 3) {
            showObjectsModalBottomSheet(context);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
