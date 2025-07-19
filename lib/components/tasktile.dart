// ignore_for_file: must_be_immutable

import 'package:audioplayers/audioplayers.dart';
import 'package:bloom/notifications/notification.dart';
import 'package:bloom/screens/task_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class TaskTile extends StatefulWidget {
  bool isCompleted;
  final String taskTitle;
  final String taskNotes;
  final String taskId;
  final int taskUniqueId;
  final String taskGroup;
  final List taskGroups;
  final DateTime taskDateTime;
  final DateTime addedOn;
  final int priorityLevel;
  final String priorityLevelString;
  final String taskMode;
  final EdgeInsetsGeometry? innerPadding;
  final BoxDecoration? decoration;
  TaskTile({
    super.key,
    required this.taskTitle,
    required this.taskNotes,
    required this.isCompleted,
    required this.taskId,
    required this.taskUniqueId,
    required this.taskGroup,
    required this.taskGroups,
    required this.taskDateTime,
    required this.priorityLevel,
    required this.priorityLevelString,
    required this.addedOn,
    required this.taskMode,
    this.innerPadding,
    this.decoration,
  });

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final now = DateTime.now();
  final player = AudioPlayer(playerId: 'task_audio_id');

  DocumentReference get _documentReference => _firestore
      .collection('users')
      .doc(userId)
      .collection('tasks')
      .doc(widget.taskId);

  Future<void> updateTask(
      DocumentReference? documentReference, bool newValue) async {
    if (documentReference != null) {
      await documentReference.update({'isCompleted': newValue});
      // Set the subTasks isCompleted to true
      if (newValue) {
        // Only update subtasks if the main task is marked as completed
        final subTasksSnapshot =
            await documentReference.collection('subTasks').get();

        for (var subTask in subTasksSnapshot.docs) {
          await subTask.reference.update({'isCompleted': true});
        }
      }
    } else {}
  }

  @override
  Widget build(BuildContext context) {
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
                    .doc(widget.taskId)
                    .delete();
                NotificationService.cancelNotification(widget.taskUniqueId);
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
                        Text(
                          'Deleted: ',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color),
                        ),
                        Text(
                          widget.taskTitle,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color),
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
                child: Icon(
                  Icons.delete_rounded,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
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
            builder: (context) => ShowTaskDetailsScreen(
              isCompleted: widget.isCompleted,
              taskTitle: widget.taskTitle,
              taskNotes: widget.taskNotes,
              taskId: widget.taskId,
              taskUniqueId: widget.taskUniqueId,
              taskGroup: widget.taskGroup,
              taskGroups: widget.taskGroups,
              taskDateTime: widget.taskDateTime,
              priorityLevel: widget.priorityLevel,
              addedOn: widget.addedOn,
              priorityLevelString: widget.priorityLevelString,
              taskMode: widget.taskMode,
            ),
          ),
        ),
        child: Container(
          padding: widget.innerPadding ?? const EdgeInsets.all(0),
          decoration: widget.decoration ?? BoxDecoration(),
          child: Row(
            children: [
              // Checkbox for the task
              Checkbox(
                value: widget.isCompleted,
                onChanged: (newValue) async {
                  setState(() {
                    // Delay the task removal
                    Future.delayed(const Duration(milliseconds: 1000),
                        () async {
                      final updateData = {'isCompleted': newValue};
                      updateTask(
                          _documentReference, updateData['isCompleted']!);

                      if (newValue == true) {
                        player.setVolume(1);
                        await player
                            .play(AssetSource('audio/task_completed.mp3'));
                        NotificationService.cancelNotification(
                            widget.taskUniqueId);
                      }
                    });
                    widget.isCompleted =
                        newValue!; // Update local state (optional)
                  });
                  if (widget.isCompleted) {
                    // Generate a date from the task date
                    final taskCompletedDate = DateTime(
                        widget.taskDateTime.year,
                        widget.taskDateTime.month,
                        widget.taskDateTime.day,
                        0,
                        0,
                        0);
                    // Save the reference to only the date of this task in a streaks collections in users collection
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .collection('streaks')
                        .doc('streaks')
                        .set({
                      'tasksCompletedDates':
                          FieldValue.arrayUnion([taskCompletedDate]),
                    }, SetOptions(merge: true));
                  }
                },
                side: BorderSide(
                    color: widget.priorityLevel == 0
                        ? Theme.of(context).iconTheme.color!
                        : widget.priorityLevel == 1
                            ? Colors.red
                            : widget.priorityLevel == 2
                                ? Colors.amber
                                : Colors.blue),
                activeColor: widget.priorityLevel == 0
                    ? Theme.of(context).iconTheme.color
                    : widget.priorityLevel == 1
                        ? Colors.red
                        : widget.priorityLevel == 2
                            ? Colors.amber
                            : Colors.blue,
                checkColor: Theme.of(context).scaffoldBackgroundColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
              ),
              const SizedBox(
                width: 4,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.taskTitle,
                      maxLines: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                        decoration: widget.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationStyle: TextDecorationStyle.solid,
                        decorationThickness: 3,
                      ),
                    ),
                    if (widget.taskGroup != '')
                      Text(
                        widget.taskGroup,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    widget.taskDateTime.isBefore(
                              DateTime(
                                now.year,
                                now.month,
                                now.day,
                                now.hour,
                                now.minute - 1,
                                now.second,
                              ),
                            ) &&
                            widget.isCompleted == false
                        ? const Text(
                            'Overdue',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                                fontSize: 12),
                          )
                        : const SizedBox()
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  widget.taskDateTime.isBefore(
                            DateTime(
                              now.year,
                              now.month,
                              now.day,
                              now.hour,
                              now.minute - 1,
                              now.second,
                            ),
                          ) &&
                          widget.isCompleted == false
                      ? Text(
                          DateFormat.MEd().format(widget.taskDateTime),
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w500),
                        )
                      : Text(
                          DateFormat.MEd().format(widget.taskDateTime),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                  widget.taskDateTime.isBefore(
                            DateTime(
                              now.year,
                              now.month,
                              now.day,
                              now.hour,
                              now.minute - 1,
                              now.second,
                            ),
                          ) &&
                          widget.isCompleted == false
                      ? Text(
                          DateFormat('h:mm a').format(widget.taskDateTime),
                          maxLines: 1,
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        )
                      : Text(
                          DateFormat('h:mm a').format(widget.taskDateTime),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey),
                        ),
                ],
              )
            ],
          ),
        ),
      ),
    ).animate().fade(delay: const Duration(milliseconds: 50));
  }
}
