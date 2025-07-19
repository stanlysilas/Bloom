import 'package:bloom/components/mybuttons.dart';
import 'package:bloom/components/mytextfield.dart';
import 'package:bloom/notifications/notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

// Add subtask Modal
class AddSubTaskModal extends StatefulWidget {
  final String mainTaskId;
  final DateTime currentDateTime;
  const AddSubTaskModal({
    super.key,
    required this.mainTaskId,
    required this.currentDateTime,
  });

  @override
  State<AddSubTaskModal> createState() => AddSubTaskModalState();
}

class AddSubTaskModalState extends State<AddSubTaskModal> {
  // Required variables
  final userId = FirebaseAuth.instance.currentUser?.uid;
  late DateTime? subTaskDate;
  late TimeOfDay? _subTaskTime;
  Importance importance = Importance.defaultImportance;
  Priority priority = Priority.defaultPriority;
  String priorityLevelString = 'Low';
  int priorityLevel = 1;
  String repeatTask = 'Never';
  int? uniqueId;
  TextEditingController taskNameController = TextEditingController();
  TextEditingController taskNotesController = TextEditingController();
  final taskNameFocusNode = FocusNode();
  final taskNotesFocusNode = FocusNode();

  // Init method to initialize
  @override
  void initState() {
    subTaskDate = widget.currentDateTime;
    _subTaskTime = TimeOfDay.fromDateTime(widget.currentDateTime);
    super.initState();
  }

  // Date selection method
  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != subTaskDate) {
      setState(() {
        subTaskDate = picked;
      });
    }
  }

  // Time selection method
  Future<void> selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _subTaskTime) {
      setState(() {
        _subTaskTime = picked;
      });
    }
  }

  // Add subtask to firebase
  Future<void> addSubTaskToFirebase(DateTime dateTime) async {
    if (taskNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot create a task without name.'),
        ),
      );
      Navigator.pop(context);
      return; // Handle empty task name (optional)
    }

    const bool isCompleted = false;
    // Get reference for subtask
    final subTasksCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(widget.mainTaskId)
        .collection('subTasks');
    // Generate document id for subTask
    final String subTaskId = subTasksCollection.doc().id;
    uniqueId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    final DateTime combinedDateTime = DateTime(
        subTaskDate!.year,
        subTaskDate!.month,
        subTaskDate!.day,
        _subTaskTime!.hour,
        _subTaskTime!.minute,
        0);

    // Add task data with dynamic field names
    await subTasksCollection.doc(subTaskId).set({
      'mainTaskId': widget.mainTaskId,
      'subTaskId': subTaskId,
      'subTaskUniqueId': uniqueId,
      'subTaskName': taskNameController.text,
      'subTaskNotes': taskNotesController.text,
      'isCompleted': isCompleted,
      'subTaskDateTime': combinedDateTime,
      'addedOn': DateTime.now(),
      'priorityLevelString': priorityLevelString,
      'priorityLevel': priorityLevel,
      'taskMode': 'SubTask'
    });

    // Pop showModal
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    taskNameController.dispose();
    taskNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // SubTask name heading
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Name',
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          // SubTask name typing field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: MyTextfield(
              controller: taskNameController,
              focusNode: taskNameFocusNode,
              hintText: 'Buy milk',
              obscureText: false,
              autoFocus: false,
              textInputType: TextInputType.text,
              minLines: 1,
              maxLines: 3,
            ),
          ),
          const SizedBox(height: 20),
          // SubTask notes heading
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Notes',
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          // SubTask notes typing field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: MyTextfield(
              controller: taskNotesController,
              focusNode: taskNotesFocusNode,
              hintText: '1L of milk packet',
              obscureText: false,
              autoFocus: false,
              textInputType: TextInputType.text,
              minLines: 1,
              maxLines: 6,
            ),
          ),
          const SizedBox(height: 20),
          // SubTask Other heading
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Other',
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          // Group the date, time and priority options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Date',
                        style: TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      // Date picker
                      Flexible(
                        child: ExtraOptionsButton(
                          decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(8)),
                          label: DateFormat('dd-MM-yyyy').format(subTaskDate!),
                          textAlign: TextAlign.center,
                          onTap: selectDate,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      const Text(
                        'Time',
                        style: TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      // Time picker
                      Flexible(
                        child: ExtraOptionsButton(
                          decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(8)),
                          label: _subTaskTime!.format(context),
                          textAlign: TextAlign.center,
                          onTap: selectTime,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      const Text(
                        'Priority',
                        style: TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(8)),
                          child: PopupMenuButton(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'None',
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.flag_rounded,
                                    ),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    Text(
                                      'None',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color),
                                    ),
                                  ],
                                ),
                                onTap: () => setState(() {
                                  priorityLevelString = 'None';
                                  priorityLevel = 0;
                                  priority = Priority.defaultPriority;
                                  importance = Importance.defaultImportance;
                                }),
                              ),
                              PopupMenuItem(
                                value: 'High',
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.flag_rounded,
                                      color: Colors.red,
                                    ),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    Text(
                                      'High',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                                onTap: () => setState(() {
                                  priorityLevelString = 'High';
                                  priorityLevel = 1;
                                  priority = Priority.high;
                                  importance = Importance.high;
                                }),
                              ),
                              PopupMenuItem(
                                value: 'Min',
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.flag_rounded,
                                      color: Colors.amber,
                                    ),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    Text(
                                      'Min',
                                      style: TextStyle(color: Colors.amber),
                                    ),
                                  ],
                                ),
                                onTap: () => setState(() {
                                  priorityLevelString = 'Min';
                                  priorityLevel = 2;
                                  priority = Priority.min;
                                  importance = Importance.min;
                                }),
                              ),
                              PopupMenuItem(
                                value: 'Low',
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.flag_rounded,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    Text(
                                      'Low',
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ],
                                ),
                                onTap: () => setState(() {
                                  priorityLevelString = 'Low';
                                  priorityLevel = 3;
                                  priority = Priority.low;
                                  importance = Importance.low;
                                }),
                              ),
                            ],
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.flag_rounded,
                                  color: priorityLevelString == 'High'
                                      ? Colors.red
                                      : priorityLevelString == 'Min'
                                          ? Colors.amber
                                          : priorityLevelString == 'Low'
                                              ? Colors.blue
                                              : Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color,
                                ),
                                Text(
                                  priorityLevelString,
                                  style: TextStyle(
                                      color: priorityLevelString == 'High'
                                          ? Colors.red
                                          : priorityLevelString == 'Min'
                                              ? Colors.amber
                                              : priorityLevelString == 'Low'
                                                  ? Colors.blue
                                                  : Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          // Submit button
          Padding(
            padding:
                const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 8.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              onTap: () async {
                // Combine the subTaskDate and _subTaskTime variables and create one single date
                DateTime? subTaskDateTime = subTaskDate;
                subTaskDateTime = DateTime(
                  subTaskDateTime!.year,
                  subTaskDateTime.month,
                  subTaskDateTime.day,
                  _subTaskTime!.hour,
                  _subTaskTime!.minute,
                );
                // Add to firebase
                await addSubTaskToFirebase(subTaskDateTime);
                // Add notification scheduling here
                NotificationService.scheduleTasksNotification(
                  uniqueId!,
                  'Sub task reminder!',
                  taskNameController.text,
                  subTaskDateTime,
                  importance,
                  priority,
                );
                // Clear form fields and selected date (optional)
                taskNameController.clear();
                taskNotesController.clear();
                // Show confirmation that task is added
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
                      'Task succesfully created!',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                  ),
                );
              },
              child: Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: Text(
                    'Create new subtask',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
