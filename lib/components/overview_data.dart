import 'package:bloom/screens/eventsandschedules_screen.dart';
import 'package:bloom/screens/tasksandhabits_screen.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class TaskData extends StatelessWidget {
  final int? numberOfTasks;

  const TaskData({super.key, this.numberOfTasks});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const TaskScreen())),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Icon(
            Iconsax.task_square5,
            size: 16,
          ),
          numberOfTasks == null
              ? const Text(
                  "... tasks",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : Text(
                  "$numberOfTasks tasks",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ],
      ),
    );
  }
}

class SchedulesData extends StatelessWidget {
  final int? numberOfSchedules;

  const SchedulesData({super.key, this.numberOfSchedules});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const SchedulesScreen())),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Icon(
            Iconsax.calendar5,
            size: 18,
          ),
          numberOfSchedules == null
              ? const Text(
                  "... events",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : Text(
                  "$numberOfSchedules events",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ],
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
