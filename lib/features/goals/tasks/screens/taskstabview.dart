import 'package:bloom/features/goals/tasks/widgets/tasktile.dart';
import 'package:bloom/features/objects/shared/widgets/filter_strip.dart';
import 'package:bloom/models/task_model.dart';
import 'package:flutter/material.dart';

class Taskstabview extends StatefulWidget {
  final List<TaskModel> tasks;
  const Taskstabview({super.key, required this.tasks});

  @override
  State<Taskstabview> createState() => _TaskstabviewState();
}

class _TaskstabviewState extends State<Taskstabview> {
  String sortValue = 'today';

  final taskFilters = [
    const FilterOption(
      value: 'today',
      title: 'Today',
      subtitle: 'Show tasks for today',
    ),
    const FilterOption(
      value: 'oldest',
      title: 'Oldest',
      subtitle: 'Sort from oldest to recent',
    ),
    const FilterOption(
      value: 'incomplete',
      title: 'Incomplete',
      subtitle: 'Show incomplete tasks',
    ),
    const FilterOption(
      value: 'completed',
      title: 'Completed',
      subtitle: 'Show completed tasks',
    ),
    const FilterOption(
      value: 'low to high',
      title: 'Low to High',
      subtitle: 'Sort from low to high priority',
    ),
    const FilterOption(
      value: 'high to low',
      title: 'High to Low',
      subtitle: 'Sort from high to low priority',
    ),
  ];

  List<TaskModel> get filteredTasks {
    var list = [...widget.tasks];
    final now = DateTime.now();

    int getPriority(TaskModel t) => t.priorityLevel ?? 3;

    if (sortValue == 'completed') {
      list = list.where((t) => t.isCompleted == true).toList();
    } else if (sortValue == 'incomplete') {
      list = list.where((t) => t.isCompleted == false).toList();
    } else if (sortValue == 'today') {
      list = list.where((t) {
        final d = t.dateTime;
        return d.year == now.year &&
            d.month == now.month &&
            d.day == now.day &&
            t.isCompleted == false;
      }).toList();
    }

    list.sort((a, b) {
      if (sortValue == 'high to low') {
        return getPriority(a).compareTo(getPriority(b));
      }

      if (sortValue == 'low to high') {
        return getPriority(b).compareTo(getPriority(a));
      }

      if (sortValue == 'oldest') {
        return a.dateTime.compareTo(b.dateTime);
      }

      return b.dateTime.compareTo(a.dateTime);
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final tasks = filteredTasks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterStrip(
          sortValue: sortValue,
          onChanged: (value) => setState(() => sortValue = value),
          filters: taskFilters,
        ),
        Expanded(
          child: tasks.isEmpty
              ? const Center(
                  child: Column(
                    children: [
                      Image(
                        height: 200,
                        width: 200,
                        image: AssetImage(
                            'assets/images/allCompletedBackground.png'),
                      ),
                      Text(
                        'Hooray! Completed all your tasks',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        'Remember to take frequent breaks and stay hydrated!',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 14,
                      )
                    ],
                  ),
                )
              : ListView.builder(
                  key: ValueKey(sortValue),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final taskModel = tasks[index];

                    return TaskTile(
                      innerPadding:
                          const EdgeInsets.only(right: 14, top: 4, bottom: 4),
                      taskModel: taskModel,
                    );
                  }),
        ),
        const SizedBox(height: 64)
      ],
    );
  }
}
