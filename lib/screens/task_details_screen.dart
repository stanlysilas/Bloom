import 'package:bloom/components/add_sub_task.dart';
import 'package:bloom/components/subtask_tile.dart';
import 'package:bloom/screens/task_editing_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
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
  final bool isHabit;
  ShowTaskDetailsScreen(
      {super.key,
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
      required this.isHabit});

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
        title: const Text(
          'Task Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
          // Button to add subtasks
          IconButton(
            onPressed: () {
              // Show add subtask modal sheet
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width,
                  maxHeight: MediaQuery.of(context).size.height,
                ),
                builder: (BuildContext context) {
                  return Scaffold(
                    body: AddSubTaskModal(
                      mainTaskId: widget.taskId,
                      currentDateTime: DateTime.now(),
                    ),
                  );
                },
                showDragHandle: true,
              );
            },
            icon: const Icon(Iconsax.add),
            tooltip: 'Add subtask',
          ),
          // Button for more options like edit, delete etc
          PopupMenuButton(
            color: Theme.of(context).scaffoldBackgroundColor,
            popUpAnimationStyle:
                AnimationStyle(duration: const Duration(milliseconds: 500)),
            itemBuilder: (context) => [
              widget.taskMode == 'MainTask'
                  ? PopupMenuItem(
                      value: 'edit',
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => TaskEditingScreen(
                                taskNotes: widget.taskNotes,
                                taskName: widget.taskTitle,
                                taskDateTime: widget.taskDateTime,
                                isMaintask: widget.taskMode == 'MainTask'
                                    ? true
                                    : false,
                                taskId: widget.taskId,
                                taskUniqueId: widget.taskUniqueId,
                                priorityLevel: widget.priorityLevel,
                                priorityLevelString: widget.priorityLevelString,
                                subTaskId: widget.taskId,
                              ))),
                      child: Text(
                        'Edit',
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color),
                      ),
                    )
                  : const PopupMenuItem(
                      enabled: false,
                      child: SizedBox(),
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
                      .doc(widget.taskId)
                      .delete();
                  // Show confirmation that task is deleted
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Task deleted succesfully.'),
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.0),
            child: Divider(),
          ),
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.0),
            child: Divider(),
          ),
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.0),
            child: Divider(),
          ),
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
                        return Column(
                          children: [
                            SubTaskTile(
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
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 14.0, right: 14.0),
                              child: const Divider().animate().fade(
                                  delay: const Duration(milliseconds: 250)),
                            )
                          ],
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
