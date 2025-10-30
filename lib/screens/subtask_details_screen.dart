import 'package:bloom/screens/task_editing_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Displaying the details of tasks
// ignore: must_be_immutable
class SubTaskDetailsScreen extends StatefulWidget {
  bool isCompleted;
  final String taskTitle;
  final String taskNotes;
  final String mainTaskId;
  final int taskUniqueId;
  final DateTime taskDateTime;
  final DateTime addedOn;
  final int priorityLevel;
  final String priorityLevelString;
  final String taskMode;
  final String subtaskId;
  SubTaskDetailsScreen({
    super.key,
    required this.isCompleted,
    required this.taskTitle,
    required this.taskNotes,
    required this.mainTaskId,
    required this.taskUniqueId,
    required this.taskDateTime,
    required this.priorityLevel,
    required this.addedOn,
    required this.priorityLevelString,
    required this.taskMode,
    required this.subtaskId,
  });

  @override
  State<SubTaskDetailsScreen> createState() => _SubTaskDetailsScreenState();
}

class _SubTaskDetailsScreenState extends State<SubTaskDetailsScreen> {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  bool? subTaskIsChecked;
  // Main task collection docreference
  DocumentReference get documentReference => FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('tasks')
      .doc(widget.mainTaskId)
      .collection('subTasks')
      .doc(widget.subtaskId);

  // Subtask collection reference based on main task

  CollectionReference get subTaskCollectionReference =>
      documentReference.collection('subTasks');

  // Method to mark the main task as completed
  Future<void> updateTask(
      DocumentReference? documentReference, bool newValue) async {
    if (documentReference != null) {
      await documentReference.update({'isCompleted': newValue});
    } else {}
  }

  Future<void> updateSubTask(CollectionReference? collectiontReference,
      bool newValue, String subTaskId) async {
    if (collectiontReference != null) {
      await collectiontReference
          .doc(subTaskId)
          .update({'isCompleted': newValue});
    } else {}
  }

  Stream<QuerySnapshot> fetchSubTasks() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(widget.mainTaskId)
        .collection('subTasks')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        actions: [
          // Checkbox to mark the mainTask as completed
          Checkbox(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            value: widget.isCompleted,
            onChanged: (newValue) {
              setState(() {
                widget.isCompleted = newValue!; // Update local state (optional)

                final updateData = {'isCompleted': newValue};
                updateTask(documentReference,
                    updateData['isCompleted']!); // Assert non-nullness (risky)
              });
              Navigator.pop(context);
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
          ),
          // Button for more options like edit, delete etc
          PopupMenuButton(
            color: Theme.of(context).primaryColorLight,
            popUpAnimationStyle:
                AnimationStyle(duration: const Duration(milliseconds: 500)),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                enabled: widget.taskMode == 'MainTask' ? true : false,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => TaskEditingScreen(
                          taskNotes: widget.taskNotes,
                          taskName: widget.taskTitle,
                          taskDateTime: widget.taskDateTime,
                          isMaintask:
                              widget.taskMode == 'MainTask' ? true : false,
                          taskId: widget.mainTaskId,
                          taskUniqueId: widget.taskUniqueId,
                          priorityLevel: widget.priorityLevel,
                          priorityLevelString: widget.priorityLevelString,
                          subTaskId: widget.subtaskId,
                        ))),
                child: Text(
                  'Edit',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
              ),
              PopupMenuItem(
                value: 'Delete',
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  // Delete the task from database
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('tasks')
                      .doc(widget.mainTaskId)
                      .collection('subTasks')
                      .doc(widget.subtaskId)
                      .delete();
                  // Show confirmation that task is deleted
                  ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    margin: const EdgeInsets.all(6),
                    behavior: SnackBarBehavior.floating,
                    showCloseIcon: true,
                    closeIconColor:
                        Theme.of(context).textTheme.bodyMedium?.color,
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    content: Text(
                      'Task deleted succesfully',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                  ),
                );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name of the mainTask
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Text(
              widget.taskTitle,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              overflow: TextOverflow.clip,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and time of the mainTask
                Text(
                  DateFormat('EEEE dd LLL, yyyy h:mm a')
                      .format(widget.taskDateTime),
                  style: TextStyle(color: Colors.grey[700]),
                ),
                // Priority level of the mainTask
                Text(
                  "Priority ${widget.priorityLevel == 0 ? 'None' : widget.priorityLevel == 1 ? 'High' : widget.priorityLevel == 2 ? 'Mid' : 'Low'}",
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          const Divider(),
          // Display notes of the maintask
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: const Text(
              'Notes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Text(
              widget.taskNotes,
              overflow: TextOverflow.clip,
            ),
          ),
        ],
      ),
    );
  }
}
