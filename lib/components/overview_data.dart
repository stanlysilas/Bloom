import 'package:bloom/screens/entries_screen.dart';
import 'package:bloom/screens/goals_screen.dart';
import 'package:flutter/material.dart';

class TaskData extends StatelessWidget {
  final int? numberOfTasks;

  const TaskData({super.key, this.numberOfTasks});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            fullscreenDialog: true,
            barrierDismissible: true,
            builder: (context) => const GoalsScreen(
                  tabIndex: 0,
                ))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Wrap(
            direction: Axis.vertical,
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                numberOfTasks == null ? "0" : "$numberOfTasks",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text('Tasks',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: Colors.grey))
            ],
          ),
        ),
      ),
    );
  }
}

class HabitData extends StatelessWidget {
  final int numberOfHabits;
  const HabitData({super.key, required this.numberOfHabits});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            fullscreenDialog: true,
            barrierDismissible: true,
            builder: (context) => const GoalsScreen(
                  tabIndex: 1,
                ))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Wrap(
            direction: Axis.vertical,
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$numberOfHabits",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text('Habits',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: Colors.grey))
            ],
          ),
        ),
      ),
    );
  }
}

class SchedulesData extends StatelessWidget {
  final int? numberOfSchedules;

  const SchedulesData({super.key, this.numberOfSchedules});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            fullscreenDialog: true,
            barrierDismissible: true,
            builder: (context) => const GoalsScreen(
                  tabIndex: 2,
                ))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Wrap(
            direction: Axis.vertical,
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                numberOfSchedules == null ? "0" : "$numberOfSchedules",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text('Events',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: Colors.grey))
            ],
          ),
        ),
      ),
    );
  }
}

class EntriesData extends StatelessWidget {
  final int numberOfEntries;
  const EntriesData({super.key, required this.numberOfEntries});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            fullscreenDialog: true,
            barrierDismissible: true,
            builder: (context) => const EntriesScreen())),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Wrap(
            direction: Axis.vertical,
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$numberOfEntries",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text('Entries',
                  overflow: TextOverflow.clip,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: Colors.grey))
            ],
          ),
        ),
      ),
    );
  }
}

class NumberOfEntries extends StatelessWidget {
  final int? numberOfEntries;

  const NumberOfEntries({super.key, this.numberOfEntries});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              numberOfEntries == 0 ? "..." : "$numberOfEntries",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              numberOfEntries == 1 ? "Entry made" : "Entries made",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class NumberOfTasks extends StatelessWidget {
  final int? completedTasks;

  const NumberOfTasks({super.key, this.completedTasks});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              completedTasks == 0 ? "..." : "$completedTasks",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              "Tasks checked",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class NumberOfEvents extends StatelessWidget {
  final int? attendedEvents;

  const NumberOfEvents({super.key, this.attendedEvents});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              attendedEvents == 0 ? "..." : "$attendedEvents",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              "Events attended",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
