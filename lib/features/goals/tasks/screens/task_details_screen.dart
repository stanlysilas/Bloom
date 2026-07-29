import 'package:bloom/core/widgets/bloom_buttons.dart';
import 'package:bloom/features/goals/tasks/widgets/add_sub_task.dart';
import 'package:bloom/core/widgets/delete_confirmation_dialog.dart';
import 'package:bloom/features/goals/tasks/widgets/subtask_tile.dart';
import 'package:bloom/features/goals/tasks/screens/task_editing_screen.dart';
import 'package:bloom/models/task_model.dart';
import 'package:bloom/services/firebase/task_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ShowTaskDetailsScreen extends StatefulWidget {
  final TaskModel taskModel;
  const ShowTaskDetailsScreen({
    super.key,
    required this.taskModel,
  });

  @override
  State<ShowTaskDetailsScreen> createState() => _ShowTaskDetailsScreenState();
}

class _ShowTaskDetailsScreenState extends State<ShowTaskDetailsScreen> {
  late TaskModel taskModel;
  late bool isCompleted = false;
  final userId = FirebaseAuth.instance.currentUser?.uid;
  bool? subTaskIsChecked;

  DocumentReference get documentReference => FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('tasks')
      .doc(taskModel.objectId);

  CollectionReference get subTaskCollectionReference =>
      documentReference.collection('subTasks');

  @override
  void initState() {
    super.initState();
    taskModel = widget.taskModel;
    isCompleted = taskModel.isCompleted;
  }

  Stream<QuerySnapshot> fetchSubTasks() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskModel.objectId)
        .collection('subTasks')
        .orderBy('subTaskDateTime', descending: true)
        .snapshots();
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
    final color = _priorityColor(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Details',
            style: TextStyle(
                fontFamily: 'ClashGrotesk', fontWeight: FontWeight.w500)),
        actions: [
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
          // Button to add subtasks
          BloomIconButton(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (BuildContext context) {
                  return AddSubTaskModal(
                    mainTaskId: taskModel.objectId,
                    currentDateTime: DateTime.now(),
                  );
                },
                showDragHandle: true,
              );
            },
            icon: Icon(Icons.add_rounded),
          ),
          // Button for more options like edit, delete etc
          PopupMenuButton(
            iconColor: Colors.grey,
            style: ButtonStyle(
                // shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                //     borderRadius: BorderRadiusGeometry.only(
                //         topLeft: Radius.circular(4),
                //         topRight: Radius.circular(100),
                //         bottomLeft: Radius.circular(4),
                //         bottomRight: Radius.circular(100)))),
                backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.surfaceContainer)),
            popUpAnimationStyle:
                AnimationStyle(duration: const Duration(milliseconds: 500)),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => TaskEditingScreen(
                          taskNotes: taskModel.description ?? '',
                          taskName: taskModel.name,
                          taskDateTime: taskModel.dateTime,
                          taskId: taskModel.objectId,
                          taskUniqueId: taskModel.uniqueNotificationId ?? 0,
                          priorityLevel: taskModel.priorityLevel ?? 3,
                          priorityLevelString:
                              taskModel.priorityLevelString ?? 'Low',
                          subTaskId: taskModel.objectId,
                        ))),
                child: Text('Edit'),
              ),
              PopupMenuItem(
                value: 'Delete',
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  showAdaptiveDialog(
                      context: context,
                      builder: (context) {
                        return DeleteConfirmationDialog(
                          objectName: taskModel.name,
                          onPressed: () async {
                            // Delete the task from database
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .collection('tasks')
                                .doc(taskModel.objectId)
                                .delete();
                            // Show confirmation that task is deleted
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                margin: const EdgeInsets.all(6),
                                behavior: SnackBarBehavior.floating,
                                showCloseIcon: true,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                content: Text('Task deleted succesfully'),
                              ),
                            );
                            Navigator.pop(context); // Close the dialog.
                            Navigator.pop(
                                context); // Close the deleted task details screen.
                          },
                        );
                      });
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
              taskModel.name,
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
                      .format(taskModel.dateTime),
                  style: TextStyle(color: Colors.grey[700]),
                ),
                // Priority level of the mainTask
                Text(
                  "Priority ${taskModel.priorityLevel == 0 ? 'None' : taskModel.priorityLevel == 1 ? 'High' : taskModel.priorityLevel == 2 ? 'Mid' : 'Low'}",
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          Divider(),
          // Task groups of the maintask
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.0),
            child: Text(
              'Group',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Text(
              taskModel.groups!.join(', '),
              overflow: TextOverflow.clip,
            ),
          ),
          Divider(),
          // Display notes of the maintask
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.0),
            child: Text(
              'Notes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Text(
              taskModel.description ?? '',
              overflow: TextOverflow.clip,
            ),
          ),
          Divider(),
          // Display subtasks
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.0),
            child: Text(
              'Sub tasks',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: fetchSubTasks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: const Skeletonizer(
                      enabled: true,
                      child: ListTile(
                        leading: Icon(Icons.abc),
                        title: Text(
                          'So this is the text of the title of the object here...',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          maxLines: 1,
                        ),
                        subtitle: Text(
                          'So this is the text of the subtitle of the object here...',
                          maxLines: 1,
                        ),
                        trailing: Text('End'),
                      ),
                    ).animate().fade(delay: const Duration(milliseconds: 50)),
                  );
                }
                if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: Text(
                      'Click on the + icon above to add a sub task.',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return const Center(
                    child:
                        Text('Encountered an error while getting subtasks...'),
                  );
                }
                final subTasks = snapshot.data!.docs;
                return SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: ListView.builder(
                      itemCount: subTasks.length,
                      itemBuilder: (context, index) {
                        final data = subTasks[index];
                        String subtaskName = data['subTaskName'];
                        String subTaskNotes = data['subTaskNotes'];
                        String subTaskId = data['subTaskId'];
                        bool isCompleted = data['isCompleted'];
                        int? subTaskUniqueId = data['subTaskUniqueId'];
                        Timestamp timestamp = data['subTaskDateTime'];
                        DateTime subTaskDateTime = timestamp.toDate();
                        int priorityLevel = data['priorityLevel'];
                        String priorityLevelString =
                            data['priorityLevelString'];
                        Timestamp timeStamp = data['addedOn'];
                        DateTime addedOn = timeStamp.toDate();
                        return SubTaskTile(
                          innerPadding: const EdgeInsets.only(
                              right: 14, top: 4, bottom: 4),
                          taskTitle: subtaskName,
                          taskNotes: subTaskNotes,
                          isCompleted: isCompleted,
                          mainTaskId: taskModel.objectId,
                          taskUniqueId: subTaskUniqueId ?? 0,
                          taskDateTime: subTaskDateTime,
                          priorityLevel: priorityLevel,
                          priorityLevelString: priorityLevelString,
                          addedOn: addedOn,
                          taskMode: 'subTask',
                          subTaskId: subTaskId,
                        );
                      }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
