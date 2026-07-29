import 'package:bloom/core/widgets/delete_confirmation_dialog.dart';
import 'package:bloom/features/goals/habits/screens/habits_details_screen.dart';
import 'package:bloom/models/habit_model.dart';
import 'package:bloom/services/firebase/habit_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class HabitTile extends StatelessWidget {
  final HabitModel habitModel;
  final EdgeInsetsGeometry? innerPadding;
  final EdgeInsetsGeometry? margin;

  const HabitTile({
    super.key,
    required this.habitModel,
    this.innerPadding,
    this.margin,
  });

  bool _isCompletedToday(HabitModel habit) {
    final now = DateTime.now();
    final key =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    return habit.completedDates.contains(key);
  }

  @override
  Widget build(BuildContext context) {
    final isCompletedToday = _isCompletedToday(habitModel);

    return Slidable(
      key: ValueKey(habitModel.objectId),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => DeleteConfirmationDialog(
                    objectName: habitModel.name,
                    onPressed: () async {
                      HabitService.deleteHabit(habitModel);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.delete_rounded,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => HabitsDetailsScreen(
                habitName: habitModel.name,
                habitNotes: habitModel.description ?? '',
                habitDateTime: habitModel.dateTime,
                habitGroups: habitModel.groups ?? const [],
                habitId: habitModel.objectId,
                habitUniqueId: habitModel.uniqueNotificationId ?? 0,
                addedOn: habitModel.addedOn,
                daysOfWeek: habitModel.daysOfWeek,
                completedDates: habitModel.completedDates,
              ),
            ),
          );
        },
        child: Container(
          margin: margin,
          padding: innerPadding,
          child: Row(
            children: [
              _HabitIcon(),
              const SizedBox(width: 8),
              Expanded(
                child: _HabitContent(
                  habit: habitModel,
                  isCompletedToday: isCompletedToday,
                ),
              ),
              _HabitStats(
                habit: habitModel,
                isCompletedToday: isCompletedToday,
              ),
              Checkbox(
                value: isCompletedToday,
                onChanged: (_) {
                  HabitService.toggleToday(habitModel);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HabitIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: Icon(
        Icons.repeat,
        color: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
    );
  }
}

class _HabitContent extends StatelessWidget {
  final HabitModel habit;
  final bool isCompletedToday;

  const _HabitContent({
    required this.habit,
    required this.isCompletedToday,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          habit.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
        if ((habit.description ?? '').isNotEmpty)
          Text(
            habit.description!,
            style: const TextStyle(color: Colors.grey),
            overflow: TextOverflow.ellipsis,
          ),
        Text(
          "At ${DateFormat('h:mm a').format(habit.dateTime)}",
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}

class _HabitStats extends StatelessWidget {
  final HabitModel habit;
  final bool isCompletedToday;

  const _HabitStats({
    required this.habit,
    required this.isCompletedToday,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCompletedToday ? null : Theme.of(context).colorScheme.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${isCompletedToday ? '🔥' : '⚠️'}: ${habit.currentStreak} days',
          style: TextStyle(color: color),
        ),
        Text(
          'Best: ${habit.bestStreak}',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
