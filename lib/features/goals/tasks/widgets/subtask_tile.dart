// ignore_for_file: must_be_immutable

import 'package:audioplayers/audioplayers.dart';
import 'package:bloom/models/task_model.dart';
import 'package:bloom/services/firebase/notification.dart';
import 'package:bloom/features/goals/tasks/screens/subtask_details_screen.dart';
import 'package:bloom/services/firebase/task_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class SubTaskTile extends StatelessWidget {
  final TaskModel subTaskModel;
  final EdgeInsetsGeometry? innerPadding;
  final BoxDecoration? decoration;
  SubTaskTile({
    super.key,
    required this.subTaskModel,
    this.innerPadding,
    this.decoration,
  });

  final String userId = FirebaseAuth.instance.currentUser!.uid;

  final now = DateTime.now();

  final player = AudioPlayer(playerId: 'task_audio_id');

  Future<void> updateTask(
      DocumentReference? documentReference, bool newValue) async {
    if (documentReference != null) {
      await documentReference.update({'isCompleted': newValue});
    } else {}
  }

  bool _isOverdue(TaskModel task) {
    final now = DateTime.now();
    return task.dateTime.isBefore(now) && !task.isCompleted;
  }

  Color _priorityColor(BuildContext context) {
    switch (subTaskModel.priorityLevel) {
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
    final isOverdue = _isOverdue(subTaskModel);
    final color = _priorityColor(context);

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: InkWell(
              onTap: () async {
                final user = FirebaseAuth.instance.currentUser;
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .collection('tasks')
                    .doc(subTaskModel.parentId)
                    .collection('subTasks')
                    .doc(subTaskModel.objectId)
                    .delete();
                NotificationService.cancelNotification(
                    subTaskModel.uniqueNotificationId ?? 0);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    margin: const EdgeInsets.all(6),
                    behavior: SnackBarBehavior.floating,
                    showCloseIcon: true,
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    content: Wrap(
                      children: [
                        Text('Deleted: '),
                        Text(
                          subTaskModel.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.delete_rounded),
              ),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SubTaskDetailsScreen(
              subTaskModel: subTaskModel,
            ),
          ),
        ),
        child: Container(
          padding: innerPadding ?? EdgeInsets.zero,
          decoration: decoration,
          child: Row(
            children: [
              // Checkbox for the task
              Checkbox(
                value: subTaskModel.isCompleted,
                onChanged: (value) async {
                  if (value == null) return;
                  debugPrint("Subtask parent path: ${subTaskModel.parentPath}");

                  TaskService.toggleNode(
                      task: subTaskModel,
                      path: subTaskModel.parentPath,
                      isCompleted: value);
                  // setState(() {
                  //   // Delay the task removal
                  //   Future.delayed(const Duration(milliseconds: 1000),
                  //       () async {
                  //     final updateData = {'isCompleted': newValue};
                  //     updateTask(
                  //         _documentReference, updateData['isCompleted']!);

                  //     if (newValue == true) {
                  //       player.setVolume(1);
                  //       await player
                  //           .play(AssetSource('audio/task_completed.mp3'));
                  //       NotificationService.cancelNotification(
                  //           widget.taskUniqueId);
                  //     }
                  //   });
                  //   widget.isCompleted =
                  //       newValue!; // Update local state (optional)
                  // });
                  // if (widget.isCompleted) {
                  //   // Generate a date from the task date
                  //   final taskCompletedDate = DateTime(
                  //       widget.taskDateTime.year,
                  //       widget.taskDateTime.month,
                  //       widget.taskDateTime.day,
                  //       0,
                  //       0,
                  //       0);
                  //   // Save the reference to only the date of this task in a streaks collections in users collection
                  //   await FirebaseFirestore.instance
                  //       .collection('users')
                  //       .doc(userId)
                  //       .collection('streaks')
                  //       .doc('streaks')
                  //       .set({
                  //     'tasksCompletedDates':
                  //         FieldValue.arrayUnion([taskCompletedDate]),
                  //   }, SetOptions(merge: true));
                  // }
                },
                side: BorderSide(color: color),
                activeColor: color,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(
                width: 4,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subTaskModel.name,
                      maxLines: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        overflow: TextOverflow.ellipsis,
                        decoration: subTaskModel.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationStyle: TextDecorationStyle.solid,
                        decorationThickness: 3,
                      ),
                    ),
                    isOverdue
                        ? const Text(
                            'Overdue',
                            style: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.w500),
                          )
                        : const SizedBox()
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  isOverdue
                      ? Text(
                          DateFormat.MEd().format(subTaskModel.dateTime),
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w500),
                        )
                      : Text(
                          DateFormat.MEd().format(subTaskModel.dateTime),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                  isOverdue
                      ? Text(
                          DateFormat('h:mm a').format(subTaskModel.dateTime),
                          maxLines: 1,
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        )
                      : Text(
                          DateFormat('h:mm a').format(subTaskModel.dateTime),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
