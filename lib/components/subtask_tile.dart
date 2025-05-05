// ignore_for_file: must_be_immutable

import 'package:audioplayers/audioplayers.dart';
import 'package:bloom/notifications/notification.dart';
import 'package:bloom/screens/subtask_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class SubTaskTile extends StatefulWidget {
  bool isCompleted;
  final String taskTitle;
  final String taskNotes;
  final String mainTaskId;
  final String subTaskId;
  final int taskUniqueId;
  final DateTime taskDateTime;
  final DateTime addedOn;
  final int priorityLevel;
  final String priorityLevelString;
  final String taskMode;
  final EdgeInsetsGeometry? innerPadding;
  SubTaskTile({
    super.key,
    required this.taskTitle,
    required this.taskNotes,
    required this.isCompleted,
    required this.mainTaskId,
    required this.subTaskId,
    required this.taskUniqueId,
    required this.taskDateTime,
    required this.priorityLevel,
    required this.priorityLevelString,
    required this.addedOn,
    required this.taskMode,
    this.innerPadding,
  });

  @override
  State<SubTaskTile> createState() => _SubTaskTileState();
}

class _SubTaskTileState extends State<SubTaskTile> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final now = DateTime.now();
  final player = AudioPlayer(playerId: 'task_audio_id');

  DocumentReference get _documentReference => _firestore
      .collection('users')
      .doc(userId)
      .collection('tasks')
      .doc(widget.mainTaskId)
      .collection('subTasks')
      .doc(widget.subTaskId);

  Future<void> updateTask(
      DocumentReference? documentReference, bool newValue) async {
    if (documentReference != null) {
      await documentReference.update({'isCompleted': newValue});
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
                    .doc(widget.mainTaskId)
                    .collection('subTasks')
                    .doc(widget.subTaskId)
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
                  Iconsax.trash,
                  color: Theme.of(context).scaffoldBackgroundColor,
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
            builder: (context) => SubTaskDetailsScreen(
              isCompleted: widget.isCompleted,
              taskTitle: widget.taskTitle,
              taskNotes: widget.taskNotes,
              mainTaskId: widget.mainTaskId,
              subtaskId: widget.subTaskId,
              taskUniqueId: widget.taskUniqueId,
              taskDateTime: widget.taskDateTime,
              priorityLevel: widget.priorityLevel,
              addedOn: widget.addedOn,
              priorityLevelString: widget.priorityLevelString,
              taskMode: widget.taskMode,
            ),
          ),
        ),
        child: Padding(
          padding: widget.innerPadding ?? const EdgeInsets.all(0),
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
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        overflow: TextOverflow.ellipsis,
                        decoration: widget.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationStyle: TextDecorationStyle.solid,
                        decorationThickness: 3,
                      ),
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
                                color: Colors.red, fontWeight: FontWeight.w500),
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
