import 'package:bloom/components/bloom_buttons.dart';
import 'package:bloom/components/mytextfield.dart';
import 'package:bloom/notifications/notification.dart';
import 'package:bloom/responsive/dimensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class TaskEditingScreen extends StatefulWidget {
  final String taskId;
  final String taskName;
  final String taskNotes;
  final DateTime taskDateTime;
  bool? isMaintask;
  final String? subTaskId;
  final int taskUniqueId;
  final int priorityLevel;
  final String priorityLevelString;
  TaskEditingScreen(
      {super.key,
      required this.taskName,
      required this.taskNotes,
      required this.taskDateTime,
      this.isMaintask,
      required this.taskUniqueId,
      required this.taskId,
      this.subTaskId,
      required this.priorityLevel,
      required this.priorityLevelString});

  @override
  State<TaskEditingScreen> createState() => _TaskEditingScreenState();
}

class _TaskEditingScreenState extends State<TaskEditingScreen> {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  late TextEditingController newTaskNameController;
  late TextEditingController newTaskNotesController;
  final newTaskNameFocusNode = FocusNode();
  final newTaskNotesFocusNode = FocusNode();
  Importance importance = Importance.defaultImportance;
  Priority priority = Priority.defaultPriority;
  late String? priorityLevelString;
  late int? priorityLevel;
  late DateTime? taskDate;
  late TimeOfDay? _taskTime;

  // Init method to initialize
  @override
  void initState() {
    super.initState();
    taskDate = widget.taskDateTime;
    newTaskNameController = TextEditingController(text: widget.taskName);
    newTaskNotesController = TextEditingController(text: widget.taskNotes);
    _taskTime = TimeOfDay.fromDateTime(widget.taskDateTime);
    priorityLevel = widget.priorityLevel;
    priorityLevelString = widget.priorityLevelString;
  }

  // Date picker function
  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != taskDate) {
      setState(() {
        taskDate = picked;
      });
    }
  }

  // Task time selection method
  Future<void> selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _taskTime) {
      setState(() {
        _taskTime = picked;
      });
    }
  }

  // Update in firebase
  Future<void> addTaskToFirebase(DateTime dateTime) async {
    // Get the collection reference for the user's tasks
    final mainTasksCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks');

    // Generate uniqueId for tasks notifications

    // Add task to firebase based on taskMode
    if (widget.isMaintask = true) {
      await mainTasksCollection.doc(widget.taskId).update({
        'taskUniqueId': widget.taskUniqueId,
        'taskName': newTaskNameController.text.isEmpty
            ? widget.taskName
            : newTaskNameController.text.isNotEmpty &&
                    newTaskNameController.text != widget.taskName
                ? newTaskNameController.text
                : widget.taskName,
        'taskNotes': newTaskNotesController.text.isEmpty
            ? widget.taskNotes
            : newTaskNotesController.text.isNotEmpty &&
                    newTaskNotesController.text != widget.taskNotes
                ? newTaskNotesController.text
                : widget.taskNotes,
        'taskDateTime': dateTime,
        'addedOn': DateTime.now(),
        'priorityLevelString': priorityLevelString,
        'priorityLevel': priorityLevel,
        'taskMode': 'MainTask'
      });
    } else {
      await mainTasksCollection
          .doc(widget.taskId)
          .collection('subTasks')
          .doc(widget.subTaskId)
          .update({
        'subTaskUniqueId': widget.taskUniqueId,
        'subTaskName': newTaskNameController.text,
        'subTaskNotes': newTaskNotesController.text,
        'subTaskDateTime': dateTime,
        'addedOn': DateTime.now(),
        'priorityLevelString': priorityLevelString,
        'priorityLevel': priorityLevel,
        'taskMode': 'SubTask'
      });
    }

    // Pop showModal
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Editing task'),
      ),
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.width > mobileWidth
              ? MediaQuery.of(context).size.width * 0.7
              : MediaQuery.of(context).size.height * 0.9,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Task name heading
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
              // Task name typing field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: MyTextfield(
                    controller: newTaskNameController,
                    focusNode: newTaskNameFocusNode,
                    hintText: widget.taskName,
                    obscureText: false,
                    autoFocus: false,
                    textInputType: TextInputType.text),
              ),
              const SizedBox(height: 20),
              // Task notes heading
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
              // Task notes typing field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: MyTextfield(
                    controller: newTaskNotesController,
                    focusNode: newTaskNotesFocusNode,
                    hintText:
                        widget.taskNotes == '' ? 'Notes' : widget.taskNotes,
                    obscureText: false,
                    autoFocus: false,
                    textInputType: TextInputType.text),
              ),
              const SizedBox(height: 20),
              // Task Other heading
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
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
                            child: BloomMaterialListTile(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              label: DateFormat('dd-MM-yyyy').format(taskDate!),
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
                            child: BloomMaterialListTile(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              label: _taskTime!.format(context),
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
                              width: double.maxFinite,
                              decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(8)),
                              child: PopupMenuButton(
                                icon: Row(
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
                                      priorityLevelString!,
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
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
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
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (MediaQuery.of(context).size.width > mobileWidth)
                const SizedBox(
                  height: 24,
                ),
              if (MediaQuery.of(context).size.width < mobileWidth)
                const Spacer(),
              // Submit button
              Padding(
                padding:
                    const EdgeInsets.only(left: 15.0, right: 15.0, top: 8.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () async {
                    // Combine the taskDate and _taskTime variables and create one single date
                    DateTime? taskDateTime = taskDate;
                    taskDateTime = DateTime(
                      taskDateTime!.year,
                      taskDateTime.month,
                      taskDateTime.day,
                      _taskTime!.hour,
                      _taskTime!.minute,
                    );
                    await addTaskToFirebase(taskDateTime);
                    // Add notification scheduling here
                    NotificationService.scheduleTasksNotification(
                      widget.taskUniqueId,
                      'Task reminder!',
                      newTaskNameController.text,
                      taskDateTime,
                      importance,
                      priority,
                    );
                    // Show confirmation that task is added
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Task succesfully updated!'),
                      ),
                    );

                    // Clear form fields
                    newTaskNameController.clear();
                    newTaskNotesController.clear();
                  },
                  child: Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        'Update task',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
