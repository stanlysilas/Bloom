import 'package:bloom/screens/entries_screen.dart';
import 'package:bloom/screens/goals_screen.dart';
import 'package:flutter/material.dart';

class TaskData extends StatelessWidget {
  final int? numberOfTasks;

  const TaskData({super.key, this.numberOfTasks});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).primaryColorLight),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const GoalsScreen(
                  tabIndex: 0,
                ))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              numberOfTasks == null ? "0" : "$numberOfTasks",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
            ),
            Text('Pending')
          ],
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
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).primaryColorLight),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const GoalsScreen(
                  tabIndex: 1,
                ))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "$numberOfHabits",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
            ),
            Text('Habits')
          ],
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
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).primaryColorLight),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const GoalsScreen(
                  tabIndex: 2,
                ))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              numberOfSchedules == null ? "0" : "$numberOfSchedules",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
            ),
            Text('Events')
          ],
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
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).primaryColorLight),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const EntriesScreen())),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "$numberOfEntries",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
            ),
            Text('Entries')
          ],
        ),
      ),
    );
  }
}

class NumberOfEntriesInYear extends StatelessWidget {
  final int? numberOfEntriesInYear;

  const NumberOfEntriesInYear({super.key, this.numberOfEntriesInYear});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.book_rounded,
              color: Colors.indigo,
              size: 16,
            ),
            Text(
              "$numberOfEntriesInYear/Year",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Text(
          numberOfEntriesInYear == 1 ? "Entry made" : "Entries made",
          style: TextStyle(color: Colors.grey[700], fontSize: 12),
        ),
      ],
    );
  }
}

class NumberOfTasksInYear extends StatelessWidget {
  final int? completedTasksInYear;

  const NumberOfTasksInYear({super.key, this.completedTasksInYear});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 16,
            ),
            Text(
              "$completedTasksInYear/Year",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Text(
          "Tasks Checked",
          style: TextStyle(color: Colors.grey[700], fontSize: 12),
        ),
      ],
    );
  }
}

class NumberOfEventsInYear extends StatelessWidget {
  final int? attendedEventsInYear;

  const NumberOfEventsInYear({super.key, this.attendedEventsInYear});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.calendar_month_rounded,
              color: Colors.red,
              size: 16,
            ),
            Text(
              "$attendedEventsInYear/Year",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Text(
          "Events Attended",
          style: TextStyle(color: Colors.grey[700], fontSize: 12),
        ),
      ],
    );
  }
}
