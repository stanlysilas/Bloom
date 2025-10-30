import 'package:bloom/components/bloom_buttons.dart';
import 'package:bloom/components/mytextfield.dart';
import 'package:bloom/notifications/notification.dart';
import 'package:bloom/responsive/dimensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddTaskOrHabitModal extends StatefulWidget {
  final DateTime currentDateTime;
  final bool? isHabit;
  const AddTaskOrHabitModal(
      {super.key, required this.currentDateTime, this.isHabit});

  @override
  State<AddTaskOrHabitModal> createState() => AddTaskOrHabitModalState();
}

enum TaskMode { mainTask, subTask }

class AddTaskOrHabitModalState extends State<AddTaskOrHabitModal> {
  // Required variables
  final userId = FirebaseAuth.instance.currentUser?.uid;
  late DateTime? taskDate;
  late TimeOfDay? _taskTime;
  Importance importance = Importance.defaultImportance;
  Priority priority = Priority.defaultPriority;
  String priorityLevelString = 'Low';
  int priorityLevel = 3;
  String repeatTask = 'Never';
  int? uniqueId;
  int? habitsUniqueId;
  bool isHabit = false;
  TextEditingController taskNameController = TextEditingController();
  TextEditingController taskNotesController = TextEditingController();
  final taskGroupsController = TextEditingController();
  final addNewTaskGroupController = TextEditingController();
  final taskNameFocusNode = FocusNode();
  final taskNotesFocusNode = FocusNode();
  final addNewTaskGroupFocusNode = FocusNode();
  List<String> defaultTaskGroups = [
    'Fitness',
    'Games',
    'Groceries',
    'Health',
    'Shopping',
    'Study',
    'Work',
    'Other',
    'Custom',
  ];
  List<String> daysOfWeekString = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  int? daysOfWeek = 0;
  List<int> daysOfWeekInt = [];
  late List<String> taskGroups;
  final List customTaskGroups = [];
  bool? subscriptionPlan = true;

  // Init method to initialize
  @override
  void initState() {
    super.initState();
    taskDate = widget.currentDateTime;
    _taskTime = TimeOfDay.fromDateTime(widget.currentDateTime);
    checkSubscription();
    taskGroups = [];
    isHabit = widget.isHabit ?? false;
  }

  // Check the subscription plan of the user
  void checkSubscription() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final plan = data?['subscriptionPlan'];

        setState(() {
          subscriptionPlan = (plan == null || plan == 'free') ? true : false;
        });
      }
    } catch (e) {
      //
    }
  }

  // Task date selection method
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

  Future<void> addToFirebase(DateTime dateTime) async {
    const bool isCompleted = false;

    // Get the collection reference for the user's tasks
    final mainTasksCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks');
    final habitsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('habits');

    // Generate the document ID for tasks
    final String mainTaskId = mainTasksCollection.doc().id;
    // Generate uniqueId for tasks notifications
    uniqueId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    // Generate the document ID for habits
    final String habitsId = mainTasksCollection.doc().id;
    // Generate uniqueId for tasks notifications
    habitsUniqueId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    // Add task to firebase after checking habit or not
    if (isHabit == true) {
      // Save as a habit
      await habitsCollection.doc(habitsId).set({
        'habitId': habitsId,
        'habitUniqueId': habitsUniqueId,
        'habitName': taskNameController.text,
        'habitNotes': taskNotesController.text,
        'daysOfWeek': daysOfWeekInt,
        'completedDaysOfWeek': [],
        'completedDates': [],
        'habitGroups': taskGroups,
        'habitDateTime': dateTime,
        'addedOn': DateTime.now(),
        'isHabit': isHabit,
      });
    } else {
      await mainTasksCollection.doc(mainTaskId).set({
        'taskId': mainTaskId,
        'taskUniqueId': uniqueId,
        'taskName': taskNameController.text,
        'taskNotes': taskNotesController.text,
        'isCompleted': isCompleted,
        'taskGroups': taskGroups,
        'taskDateTime': dateTime,
        'addedOn': DateTime.now(),
        'priorityLevelString': priorityLevelString,
        'priorityLevel': priorityLevel,
        'taskMode': 'MainTask',
      });
    }

    // Pop showModal
    Navigator.of(context).pop();
  }

  // Show Habit intro dialog
  void showHabitIntroDialog(bool isHabitIntroShown) async {
    if (isHabitIntroShown == false) {
      showAdaptiveDialog(
          context: context,
          builder: (context) {
            return AlertDialog.adaptive(
              icon: Icon(Icons.terrain_rounded),
              title: Text('Adding a Habit'),
              content: const Text(
                  'The analytics for Habits are calculated seperately from Tasks and are also displayed separately.'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      return;
                    },
                    child: Text('Close'))
              ],
            );
          });
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isHabitIntroShown', true);
    }
  }

  @override
  void dispose() {
    taskNameController.dispose();
    taskNotesController.dispose();
    taskGroups.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.width > mobileWidth
              ? MediaQuery.of(context).size.width * 0.7
              : MediaQuery.of(context).size.height * 0.9,
          child: Column(
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
                  controller: taskNameController,
                  focusNode: taskNameFocusNode,
                  hintText: 'Buy groceries',
                  obscureText: false,
                  autoFocus: false,
                  textInputType: TextInputType.text,
                  minLines: 1,
                  maxLines: 3,
                ),
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
                  controller: taskNotesController,
                  focusNode: taskNotesFocusNode,
                  hintText: 'Milk, vegetables, meat...',
                  obscureText: false,
                  autoFocus: false,
                  textInputType: TextInputType.text,
                  minLines: 1,
                  maxLines: 6,
                ),
              ),
              const SizedBox(height: 20),
              // Task name heading
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Group(s)',
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              // Task group names field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Column(
                  children: [
                    RawAutocomplete<String>(
                      displayStringForOption: (option) {
                        return option = '';
                      },
                      fieldViewBuilder: (context, taskGroupsController,
                          focusNode, onFieldSubmitted) {
                        return TextFormField(
                          controller: taskGroupsController,
                          focusNode: focusNode,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: 'Shopping, Groceries...',
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor:
                                Theme.of(context).colorScheme.surfaceContainer,
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                          onFieldSubmitted: (String value) {
                            onFieldSubmitted;
                          },
                          onTapOutside: (event) {
                            focusNode.unfocus();
                          },
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            height: 200,
                            width: MediaQuery.of(context).size.width / 1.078,
                            padding: const EdgeInsets.only(right: 15),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainer,
                                boxShadow: [
                                  BoxShadow(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withAlpha(50),
                                      offset: Offset(0, 2),
                                      blurRadius: 16)
                                ]),
                            child: ListView.builder(
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final String option =
                                      options.elementAt(index);
                                  return InkWell(
                                    onTap: () {
                                      if (option == 'Custom') {
                                        // Add functionality to create and store new task groups
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Dialog(
                                                child: SizedBox(
                                                  height: 200,
                                                  width: 200,
                                                  child: Column(
                                                    children: [
                                                      const SizedBox(
                                                        height: 15,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    12.0),
                                                        child: MyTextfield(
                                                          controller:
                                                              addNewTaskGroupController,
                                                          focusNode:
                                                              addNewTaskGroupFocusNode,
                                                          hintText:
                                                              'Create a new task group',
                                                          obscureText: false,
                                                          textInputType:
                                                              TextInputType
                                                                  .text,
                                                          autoFocus: false,
                                                          minLines: 1,
                                                          maxLines: 2,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      // Submit button
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 12,
                                                                vertical: 8.0),
                                                        child: InkWell(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          onTap: () async {
                                                            customTaskGroups.add(
                                                                addNewTaskGroupController
                                                                    .text
                                                                    .trim());
                                                            setState(() {
                                                              if (taskGroups.contains(
                                                                  addNewTaskGroupController
                                                                      .text
                                                                      .trim())) {
                                                                return;
                                                              } else {
                                                                taskGroups.add(
                                                                    addNewTaskGroupController
                                                                        .text
                                                                        .trim());
                                                                return taskGroups
                                                                    .sort();
                                                              }
                                                            });
                                                            // Add the new task group to the user's collection separately
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .doc(userId)
                                                                .set(
                                                                    {
                                                                  'customTaskGroups':
                                                                      customTaskGroups,
                                                                },
                                                                    SetOptions(
                                                                      merge:
                                                                          true,
                                                                    ));
                                                            // Clear form field and custom task group list
                                                            addNewTaskGroupController
                                                                .clear();
                                                            customTaskGroups
                                                                .clear();
                                                          },
                                                          child: Container(
                                                            width: double
                                                                .maxFinite,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(15.0),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                'Create new group',
                                                                style: TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onPrimary,
                                                                    fontSize:
                                                                        18),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });
                                      } else {
                                        onSelected(option);
                                      }
                                    },
                                    child: ListTile(
                                      dense: true,
                                      title: Text(
                                        option,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        );
                      },
                      optionsBuilder: (textEditingValue) {
                        return defaultTaskGroups.where((String items) {
                          return items.contains(textEditingValue.text);
                        });
                      },
                      onSelected: (String item) {
                        setState(() {
                          if (taskGroups.contains(item)) {
                            return;
                          } else {
                            taskGroups.add(item);
                            return taskGroups.sort();
                          }
                        });
                      },
                    ),
                    if (taskGroups.isNotEmpty)
                      const SizedBox(
                        height: 2.5,
                      ),
                    if (taskGroups.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Divider(),
                      ),
                    if (taskGroups.isNotEmpty)
                      const SizedBox(
                        height: 2.5,
                      ),
                    if (taskGroups.isNotEmpty)
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 40,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: taskGroups.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: RawChip(
                                  onPressed: () {
                                    setState(() {
                                      taskGroups.remove(taskGroups[index]);
                                    });
                                  },
                                  backgroundColor:
                                      Theme.of(context).colorScheme.onSecondary,
                                  side: BorderSide.none,
                                  label: Text(taskGroups[index]),
                                ),
                              );
                            }),
                      ),
                    taskGroups.isEmpty
                        ? const SizedBox()
                        : const SizedBox(
                            height: 8,
                          )
                  ],
                ),
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
              // Group the date, time and priority options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      if (!isHabit)
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
                                outerPadding: const EdgeInsets.all(0),
                                innerPadding: EdgeInsets.all(6),
                                icon: SizedBox(),
                                iconLabelSpace: 0,
                                useSpacer: false,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                borderRadius: BorderRadius.circular(16),
                                label:
                                    DateFormat('dd-MM-yyyy').format(taskDate!),
                                labelStyle: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                                onTap: selectDate,
                              ),
                            ),
                          ],
                        ),
                      if (!isHabit) const Divider(),
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
                              outerPadding: const EdgeInsets.all(0),
                              innerPadding: EdgeInsets.all(6),
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              iconLabelSpace: 0,
                              useSpacer: false,
                              icon: SizedBox(),
                              borderRadius: BorderRadius.circular(16),
                              label: _taskTime!.format(context),
                              labelStyle: TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                              onTap: selectTime,
                            ),
                          ),
                        ],
                      ),
                      if (!isHabit) const Divider(),
                      if (!isHabit)
                        Row(
                          children: [
                            const Text(
                              'Priority',
                              style: TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                width: double.maxFinite,
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                    borderRadius: BorderRadius.circular(16)),
                                child: PopupMenuButton(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'None',
                                      child: Row(
                                        children: [
                                          const Icon(Icons.flag_rounded),
                                          const SizedBox(width: 4),
                                          Text('None'),
                                        ],
                                      ),
                                      onTap: () => setState(() {
                                        priorityLevelString = 'None';
                                        priorityLevel = 0;
                                        priority = Priority.defaultPriority;
                                        importance =
                                            Importance.defaultImportance;
                                      }),
                                    ),
                                    PopupMenuItem(
                                      value: 'High',
                                      child: const Row(
                                        children: [
                                          Icon(Icons.flag_rounded,
                                              color: Colors.red),
                                          SizedBox(width: 4),
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
                                          Icon(Icons.flag_rounded,
                                              color: Colors.amber),
                                          SizedBox(width: 4),
                                          Text(
                                            'Min',
                                            style:
                                                TextStyle(color: Colors.amber),
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
                                          Icon(Icons.flag_rounded,
                                              color: Colors.blue),
                                          SizedBox(width: 4),
                                          Text(
                                            'Low',
                                            style:
                                                TextStyle(color: Colors.blue),
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
                                                    : priorityLevelString ==
                                                            'Low'
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
                      const Divider(),
                      // Task repeating options
                      // Convert the task to a habit if the user opts for habit
                      BloomMaterialListTile(
                        icon: SizedBox(),
                        outerPadding: EdgeInsets.all(0),
                        innerPadding: EdgeInsets.all(2),
                        iconLabelSpace: 0,
                        label: 'Habit',
                        useSpacer: true,
                        labelStyle: const TextStyle(fontSize: 16),
                        endIcon: Switch(
                            value: isHabit,
                            onChanged: (value) async {
                              setState(() {
                                isHabit = value;
                              });
                              if (isHabit) {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                final isHabitIntroShown =
                                    prefs.getBool('isHabitIntroShown');
                                showHabitIntroDialog(
                                    isHabitIntroShown ?? false);
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  margin: const EdgeInsets.all(6),
                                  behavior: SnackBarBehavior.floating,
                                  showCloseIcon: true,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  content: Text(
                                      'Adding habits are only available with Pro subscription'),
                                ),
                              );
                            }),
                      ),
                      if (isHabit)
                        const SizedBox(
                          height: 15,
                        ),
                      if (isHabit)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ...List.generate(daysOfWeekString.length,
                                growable: false, (index) {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    daysOfWeek = index;
                                    if (daysOfWeekInt.contains(daysOfWeek)) {
                                      daysOfWeekInt.remove(daysOfWeek);
                                      daysOfWeekInt.sort();
                                    } else {
                                      daysOfWeekInt.add(daysOfWeek ?? 0);
                                      daysOfWeekInt.sort();
                                    }
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: daysOfWeekInt.any(
                                              (element) => element == index)
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .secondaryContainer,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      daysOfWeekString[index],
                                      style: TextStyle(
                                        color: daysOfWeekInt.any(
                                                (element) => element == index)
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onPrimary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSecondaryContainer,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            })
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
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8.0),
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
                    if (taskNameController.text.isEmpty) {
                      // Show warning that task name is empty
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          margin: const EdgeInsets.all(6),
                          behavior: SnackBarBehavior.floating,
                          showCloseIcon: true,
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          content: const Text(
                            'Enter at least task name to create a new task!',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    } else {
                      if (isHabit == true) {
                        await addToFirebase(taskDateTime);
                        // Schedule recurring notification for habit
                        await NotificationService
                            .scheduleRecurringHabitNotification(
                          habitsUniqueId!,
                          'Habit reminder!',
                          taskNameController.text,
                          taskDateTime,
                          daysOfWeekInt,
                          importance,
                          priority,
                        );
                        // Show confirmation that habit is added
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            margin: const EdgeInsets.all(6),
                            behavior: SnackBarBehavior.floating,
                            showCloseIcon: true,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            content: Text('Habit succesfully created!'),
                          ),
                        );
                      } else {
                        await addToFirebase(taskDateTime);
                        // Add notification scheduling here
                        await NotificationService.scheduleTasksNotification(
                          uniqueId!,
                          'Task reminder!',
                          taskNameController.text,
                          taskDateTime,
                          importance,
                          priority,
                        );
                        // Show confirmation that task is added
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            margin: const EdgeInsets.all(6),
                            behavior: SnackBarBehavior.floating,
                            showCloseIcon: true,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            content: Text('Task succesfully created!'),
                          ),
                        );
                      }
                      // Clear form fields
                      taskNameController.clear();
                      taskNotesController.clear();
                      daysOfWeekInt.clear();
                    }
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
                        isHabit == true
                            ? 'Create new habit'
                            : 'Create new task',
                        style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onPrimary),
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
