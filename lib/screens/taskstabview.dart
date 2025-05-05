import 'package:bloom/components/mybuttons.dart';
import 'package:bloom/components/tasktile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Taskstabview extends StatefulWidget {
  final DateTime focusedDay;
  final bool toggleDayView;
  final bool toggleSearch;
  const Taskstabview(
      {super.key,
      required this.focusedDay,
      required this.toggleDayView,
      required this.toggleSearch});

  @override
  State<Taskstabview> createState() => _TaskstabviewState();
}

class _TaskstabviewState extends State<Taskstabview> {
  final user = FirebaseAuth.instance.currentUser;
  String sortValue = 'Recent tasks';
  String completedSortValue = 'Incomplete';
  String priorityLevel = 'High to Low';

  // Method to fetch tasks based on filters
  Stream<QuerySnapshot> fetchTasks(DateTime day, String sortValue) {
    var dayStart = DateTime(day.year, day.month, day.day, 0, 0, 0);
    var dayEnd = DateTime(day.year, day.month, day.day, 23, 59, 59);
    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('tasks');

    // Apply date filter if toggleDayView is enabled
    if (widget.toggleDayView) {
      query = query
          .where('taskDateTime', isGreaterThanOrEqualTo: dayStart)
          .where('taskDateTime', isLessThanOrEqualTo: dayEnd);
    }

    // Apply completion filter (if not empty or null)
    if (completedSortValue == 'Completed') {
      query = query.where('isCompleted', isEqualTo: true);
    } else if (completedSortValue == 'Incomplete') {
      query = query.where('isCompleted', isEqualTo: false);
    }

    // Sorting logic based on priority and task date
    bool isPriorityHighToLow = priorityLevel == 'High to Low';
    bool isRecentTasks = sortValue == 'Recent tasks';

    query = query
        .orderBy('priorityLevel',
            descending: !isPriorityHighToLow) // High to Low or Low to High
        .orderBy('taskDateTime', descending: isRecentTasks); // Recent or Oldest

    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (!widget.toggleSearch)
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 14,
                ),
                // Filters button for tasks
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      // Functionality to show the filter and other options as a modal bottom sheet
                      showModalBottomSheet(
                          showDragHandle: true,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          isScrollControlled: true,
                          isDismissible: true,
                          useSafeArea: true,
                          constraints: BoxConstraints(
                            minWidth: double.maxFinite,
                            maxHeight: MediaQuery.of(context).size.height * 0.9,
                          ),
                          context: context,
                          builder: (context) {
                            return Column(
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                // Display a pop up menu for date filters
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14.0),
                                  child: ExtraOptionsButton(
                                    icon: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                        ),
                                        child: const Icon(
                                            Icons.date_range_outlined)),
                                    iconLabelSpace: 8,
                                    label: 'Date filters',
                                    labelStyle: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16),
                                    innerPadding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    // Display a pop up menu for date filters
                                    endIcon: PopupMenuButton(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        popUpAnimationStyle: AnimationStyle(
                                            duration: const Duration(
                                                milliseconds: 500)),
                                        child: Row(
                                          children: [
                                            Text(sortValue),
                                            const Icon(
                                                Icons.arrow_drop_down_rounded)
                                          ],
                                        ),
                                        itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: 'recent tasks',
                                                onTap: () {
                                                  setState(() {
                                                    sortValue = 'Recent tasks';
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  'Recent tasks',
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.color),
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'oldest',
                                                child: Text(
                                                  'Oldest',
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.color),
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    sortValue = 'Oldest';
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ]),
                                  ),
                                ),
                                // Display a popup menu for completed or not completed filters
                                const SizedBox(
                                  height: 6,
                                ),
                                // Display a pop up menu for completion filters
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14.0),
                                  child: ExtraOptionsButton(
                                    icon: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                        ),
                                        child:
                                            const Icon(Icons.task_alt_rounded)),
                                    iconLabelSpace: 8,
                                    label: 'Completion filters',
                                    labelStyle: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16),
                                    innerPadding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    // Display a pop up menu for completion filters
                                    endIcon: PopupMenuButton(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        popUpAnimationStyle: AnimationStyle(
                                            duration: const Duration(
                                                milliseconds: 500)),
                                        child: Row(
                                          children: [
                                            Text(completedSortValue),
                                            const Icon(
                                                Icons.arrow_drop_down_rounded)
                                          ],
                                        ),
                                        itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: 'incomplete',
                                                child: Text(
                                                  'Incomplete',
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.color),
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    completedSortValue =
                                                        'Incomplete';
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              PopupMenuItem(
                                                value: 'Completed',
                                                child: Text(
                                                  'Completed',
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.color),
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    completedSortValue =
                                                        'Completed';
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ]),
                                  ),
                                ),
                                // Display a popup menu for priority filters
                                const SizedBox(
                                  height: 6,
                                ),
                                // Display a pop up menu for priority filters
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14.0),
                                  child: ExtraOptionsButton(
                                    icon: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                        ),
                                        child: const Icon(
                                            Icons.priority_high_rounded)),
                                    iconLabelSpace: 8,
                                    label: 'Priority filters',
                                    labelStyle: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16),
                                    innerPadding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    // Display a pop up menu for priority filters
                                    endIcon: PopupMenuButton(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        popUpAnimationStyle: AnimationStyle(
                                            duration: const Duration(
                                                milliseconds: 500)),
                                        child: Row(
                                          children: [
                                            Text(priorityLevel),
                                            const Icon(
                                                Icons.arrow_drop_down_rounded)
                                          ],
                                        ),
                                        itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: 'high to low',
                                                onTap: () {
                                                  setState(() {
                                                    priorityLevel =
                                                        'High to Low';
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  'High - Low',
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.color),
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'low to high',
                                                child: Text(
                                                  'Low - High',
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.color),
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    priorityLevel =
                                                        'Low to High';
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ]),
                                  ),
                                ),
                              ],
                            );
                          });
                    },
                    child: Container(
                      width: 70,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Theme.of(context).primaryColorDark),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(
                            Iconsax.settings,
                            size: 14,
                          ),
                          Text('Filters'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: fetchTasks(widget.focusedDay, sortValue),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Skeletonizer(
                          enabled: true,
                          containersColor: Theme.of(context).primaryColorLight,
                          child: const ListTile(
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
                        )
                            .animate()
                            .fade(delay: const Duration(milliseconds: 50));
                      }
                      if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                        return const SizedBox(
                          child: Padding(
                            padding: EdgeInsets.only(left: 14.0, right: 14.0),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image(
                                    image: AssetImage(
                                        'assets/images/allCompletedBackground.png'),
                                  ),
                                  Text(
                                    'Hooray! Completed all your tasks',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    'Remember to take frequent breaks and stay hydrated!',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: 14,
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                            .animate()
                            .fade(delay: const Duration(milliseconds: 100));
                      }
                      if (snapshot.hasError) {
                        return const Center(
                          child:
                              Text('There was an error trying to fetch tasks.'),
                        );
                      }
                      List tasksList = snapshot.data!.docs;
                      return SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: tasksList.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot document = tasksList[index];
                            String taskId = document.id;
                            Map<String, dynamic> data =
                                document.data() as Map<String, dynamic>;
                            String taskName = data['taskName'];
                            String taskNotes = data['taskNotes'];
                            int taskUniqueId = data['taskUniqueId'] ?? 0;
                            bool isCompleted = data['isCompleted'];
                            Timestamp timestamp = data['taskDateTime'];
                            DateTime taskDateTime = timestamp.toDate();
                            List taskGroups = data['taskGroups'];
                            String taskGroupNames = taskGroups.join(', ');
                            Timestamp timeStamp = data['addedOn'];
                            DateTime addedOn = timeStamp.toDate();
                            int priorityLevel = data['priorityLevel'];
                            String priorityLevelString =
                                data['priorityLevelString'];
                            String taskMode = data['taskMode'];
                            bool isHabit = data['isHabit'] ?? false;
                            return Column(
                              children: [
                                TaskTile(
                                  innerPadding: const EdgeInsets.only(
                                      right: 14, top: 4, bottom: 4),
                                  taskTitle: taskName,
                                  taskNotes: taskNotes,
                                  isCompleted: isCompleted,
                                  addedOn: addedOn,
                                  taskId: taskId,
                                  taskUniqueId: taskUniqueId,
                                  taskGroup: taskGroupNames,
                                  taskGroups: [taskGroups],
                                  taskDateTime: taskDateTime,
                                  priorityLevel: priorityLevel,
                                  priorityLevelString: priorityLevelString,
                                  taskMode: taskMode,
                                  isHabit: isHabit,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14.0),
                                  child: const Divider().animate().fade(
                                      delay: const Duration(milliseconds: 250)),
                                )
                              ],
                            );
                          },
                        ),
                      );
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Task {
  final String id;
  final String title;
  final String description;

  Task({required this.id, required this.title, required this.description});
}
