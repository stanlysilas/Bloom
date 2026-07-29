import 'package:bloom/core/widgets/delete_confirmation_dialog.dart';
import 'package:bloom/features/goals/tasks/screens/task_details_screen.dart';
import 'package:bloom/models/task_model.dart';
import 'package:bloom/services/firebase/task_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class TaskTile extends StatelessWidget {
  final TaskModel taskModel;
  final EdgeInsetsGeometry? innerPadding;
  final BoxDecoration? decoration;
  final BorderRadius? borderRadius;

  const TaskTile({
    super.key,
    required this.taskModel,
    this.innerPadding,
    this.decoration,
    this.borderRadius,
  });

  bool _isOverdue(TaskModel task) {
    final now = DateTime.now();
    return task.dateTime.isBefore(now) && !task.isCompleted;
  }

  Color _priorityColor(BuildContext context) {
    switch (taskModel.priorityLevel) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.amber;
      case 3:
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = _isOverdue(taskModel);
    final color = _priorityColor(context);

    return Slidable(
      key: ValueKey(taskModel.objectId),
      closeOnScroll: true,
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          const SizedBox(width: 8),
          _DeleteButton(taskModel: taskModel),
          const SizedBox(width: 8),
        ],
      ),
      child: Material(
        borderRadius: borderRadius ?? BorderRadius.circular(0),
        child: InkWell(
          borderRadius: borderRadius ?? BorderRadius.circular(0),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ShowTaskDetailsScreen(taskModel: taskModel),
            ),
          ),
          child: Container(
            padding: innerPadding ?? EdgeInsets.zero,
            decoration: decoration,
            child: Row(
              children: [
                Checkbox(
                  value: taskModel.isCompleted,
                  onChanged: (value) {
                    if (value == null) return;

                    TaskService.toggleTask(taskModel, value);
                  },
                  activeColor: color,
                  side: BorderSide(color: color),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(4)),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _TaskContent(
                    taskModel: taskModel,
                    isOverdue: isOverdue,
                  ),
                ),
                _TaskTime(taskModel: taskModel, isOverdue: isOverdue),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskContent extends StatelessWidget {
  final TaskModel taskModel;
  final bool isOverdue;

  const _TaskContent({
    required this.taskModel,
    required this.isOverdue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          taskModel.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 18,
            decoration:
                taskModel.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        if ((taskModel.groups?.isNotEmpty ?? false))
          Text(
            taskModel.groups!.join(', '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey),
          ),
        if (isOverdue)
          const Text(
            'Overdue',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
      ],
    );
  }
}

class _TaskTime extends StatelessWidget {
  final TaskModel taskModel;
  final bool isOverdue;

  const _TaskTime({
    required this.taskModel,
    required this.isOverdue,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateFormat.MEd().format(taskModel.dateTime);
    final time = DateFormat('h:mm a').format(taskModel.dateTime);

    final color = isOverdue ? Colors.red : Colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(date,
            style: TextStyle(
                color: isOverdue ? Colors.red : null,
                fontWeight: FontWeight.w500)),
        Text(time,
            style: TextStyle(color: color), overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final TaskModel taskModel;

  const _DeleteButton({required this.taskModel});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () => showDialog(
            context: context,
            builder: (_) {
              return DeleteConfirmationDialog(
                  onPressed: () async {
                    TaskService.deleteTask(taskModel);
                    Navigator.pop(context);
                  },
                  objectName: taskModel.name);
            }),
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
    );
  }
}
