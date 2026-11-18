import 'package:bloom/core/responsive/dimensions.dart';
import 'package:bloom/features/goals/tasks/screens/task_editing_screen.dart';
import 'package:bloom/models/task_model.dart';
import 'package:bloom/services/firebase/task_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SubTaskDetailsScreen extends StatelessWidget {
  final TaskModel subTaskModel;
  SubTaskDetailsScreen({
    super.key,
    required this.subTaskModel,
  });

  final userId = FirebaseAuth.instance.currentUser?.uid;

  // Main task collection docreference
  DocumentReference get documentReference => FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('tasks')
      .doc(subTaskModel.parentId)
      .collection('subTasks')
      .doc(subTaskModel.objectId);

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
        .doc(subTaskModel.parentId)
        .collection('subTasks')
        .snapshots();
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
    final color = _priorityColor(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Details'),
          actions: [
            // Checkbox to mark the mainTask as completed
            Checkbox(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              value: subTaskModel.isCompleted,
              onChanged: (value) {
                if (value == null) return;

                TaskService.toggleNode(
                    task: subTaskModel, path: [], isCompleted: value);
              },
              side: BorderSide(color: color),
              activeColor: color,
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
                  enabled: subTaskModel.type == 'MainTask' ? true : false,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => TaskEditingScreen(
                            taskNotes: subTaskModel.description ?? '',
                            taskName: subTaskModel.name,
                            taskDateTime: subTaskModel.dateTime,
                            isMaintask:
                                subTaskModel.type == 'MainTask' ? true : false,
                            taskId: subTaskModel.parentId ?? '',
                            taskUniqueId:
                                subTaskModel.uniqueNotificationId ?? 0,
                            priorityLevel: subTaskModel.priorityLevel ?? 0,
                            priorityLevelString:
                                subTaskModel.priorityLevelString ?? 'Low',
                            subTaskId: subTaskModel.objectId,
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
                        .doc(subTaskModel.parentId)
                        .collection('subTasks')
                        .doc(subTaskModel.objectId)
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
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color),
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
        body: Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: MediaQuery.of(context).size.width > mobileWidth ? 650 : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name of the mainTask
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Text(
                    subTaskModel.name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w600),
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
                            .format(subTaskModel.dateTime),
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      // Priority level of the mainTask
                      Text(
                        "Priority ${subTaskModel.priorityLevel == 0 ? 'None' : subTaskModel.priorityLevel == 1 ? 'High' : subTaskModel.priorityLevel == 2 ? 'Mid' : 'Low'}",
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
                    subTaskModel.description ?? '',
                    overflow: TextOverflow.clip,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
