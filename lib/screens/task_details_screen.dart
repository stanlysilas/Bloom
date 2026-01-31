import 'package:bloom/components/add_sub_task.dart';
import 'package:bloom/components/delete_confirmation_dialog.dart';
import 'package:bloom/components/subtask_tile.dart';
import 'package:bloom/screens/task_editing_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

// Displaying the details of tasks
// ignore: must_be_immutable
class ShowTaskDetailsScreen extends StatefulWidget {
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
  final String? subtaskId;
  IconData? appBarLeading;
  ShowTaskDetailsScreen({
    super.key,
    required this.isCompleted,
    required this.taskTitle,
    required this.taskNotes,
    required this.taskId,
    required this.taskUniqueId,
    required this.taskGroup,
    required this.taskGroups,
    required this.taskDateTime,
    required this.priorityLevel,
    required this.addedOn,
    required this.priorityLevelString,
    required this.taskMode,
    this.subtaskId,
    this.appBarLeading,
  });

  @override
  State<ShowTaskDetailsScreen> createState() => _ShowTaskDetailsScreenState();
}

class _ShowTaskDetailsScreenState extends State<ShowTaskDetailsScreen> {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  bool? subTaskIsChecked;
  // Main task collection docreference
  DocumentReference get documentReference => FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('tasks')
      .doc(widget.taskId);

  // Subtask collection reference based on main task

  CollectionReference get subTaskCollectionReference =>
      documentReference.collection('subTasks');

  // Method to mark the main task as completed
  Future<void> updateTask(
      DocumentReference? documentReference, bool newValue) async {
    if (documentReference != null) {
      await documentReference.update({'isCompleted': newValue});
      // Update all the subtasks to true if maintask is true
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

  Stream<QuerySnapshot> fetchSubTasks() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(widget.taskId)
        .collection('subTasks')
        .orderBy('subTaskDateTime', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.surfaceContainer)),
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(widget.appBarLeading ?? Icons.arrow_back,
                color: Colors.grey)),
        title: const Text('Details',
            style: TextStyle(
                fontFamily: 'ClashGrotesk', fontWeight: FontWeight.w500)),
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
          ),
          // Button to add subtasks
          IconButton(
            style: ButtonStyle(
                // shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                //     borderRadius: BorderRadiusGeometry.only(
                //         topRight: Radius.circular(4),
                //         topLeft: Radius.circular(100),
                //         bottomRight: Radius.circular(4),
                //         bottomLeft: Radius.circular(100)))),
                backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.surfaceContainer)),
            onPressed: () {
              // Show add subtask modal sheet
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (BuildContext context) {
                  return AddSubTaskModal(
                    mainTaskId: widget.taskId,
                    currentDateTime: DateTime.now(),
                  );
                },
                showDragHandle: true,
              );
            },
            icon: Icon(
              Icons.add_rounded,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            tooltip: 'Add subtask',
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
                enabled: widget.taskMode == 'MainTask' ? true : false,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => TaskEditingScreen(
                          taskNotes: widget.taskNotes,
                          taskName: widget.taskTitle,
                          taskDateTime: widget.taskDateTime,
                          isMaintask:
                              widget.taskMode == 'MainTask' ? true : false,
                          taskId: widget.taskId,
                          taskUniqueId: widget.taskUniqueId,
                          priorityLevel: widget.priorityLevel,
                          priorityLevelString: widget.priorityLevelString,
                          subTaskId: widget.taskId,
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
                          objectName: widget.taskTitle,
                          onPressed: () async {
                            // Delete the task from database
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .collection('tasks')
                                .doc(widget.taskId)
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
              widget.taskGroup,
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
              widget.taskNotes,
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
                          mainTaskId: widget.taskId,
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
