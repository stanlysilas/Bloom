import 'package:bloom/components/tasktile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Taskstabview extends StatefulWidget {
  const Taskstabview({super.key});

  @override
  State<Taskstabview> createState() => _TaskstabviewState();
}

class _TaskstabviewState extends State<Taskstabview> {
  final user = FirebaseAuth.instance.currentUser;
  String sortValue = 'Recent tasks';
  String completedSortValue = 'Incomplete';
  String priorityLevel = 'High to Low';

  // Method to fetch tasks based on filters
  Stream<QuerySnapshot> fetchTasks(String sortValue) {
    final day = DateTime.now();
    var dayStart = DateTime(day.year, day.month, day.day, 0, 0, 0);
    var dayEnd = DateTime(day.year, day.month, day.day, 23, 59, 59);
    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('tasks');

    if (sortValue == 'Today') {
      query = query
          .where('taskDateTime', isGreaterThanOrEqualTo: dayStart)
          .where('taskDateTime', isLessThanOrEqualTo: dayEnd);
    } else if (completedSortValue == 'Completed') {
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

  // State update method
  void stateUpdate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                spacing: 8,
                children: [
                  // Default sorting button
                  RawChip(
                    backgroundColor: sortValue != 'Recent tasks' ||
                            completedSortValue != 'Incomplete' ||
                            priorityLevel != 'High to Low'
                        ? Theme.of(context).primaryColorLight
                        : Theme.of(context).primaryColor,
                    side: BorderSide.none,
                    labelStyle: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                    iconTheme: IconThemeData(
                        color: sortValue != 'Recent tasks' ||
                                completedSortValue != 'Incomplete' ||
                                priorityLevel != 'High to Low'
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).textTheme.bodyMedium?.color),
                    onPressed: () {
                      setState(() {
                        sortValue = 'Recent tasks';
                        completedSortValue = 'Incomplete';
                        priorityLevel = 'High to Low';
                      });
                    },
                    avatar: Icon(sortValue != 'Recent tasks' ||
                            completedSortValue != 'Incomplete' ||
                            priorityLevel != 'High to Low'
                        ? Icons.filter_list_off_rounded
                        : Icons.check_rounded),
                    label: Text('Default'),
                  ),
                  // Custom filters button
                  RawChip(
                    backgroundColor: sortValue != 'Recent tasks' ||
                            completedSortValue != 'Incomplete' ||
                            priorityLevel != 'High to Low'
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).primaryColorLight,
                    side: BorderSide.none,
                    labelStyle: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                    iconTheme: IconThemeData(
                        color: sortValue != 'Recent tasks' ||
                                completedSortValue != 'Incomplete' ||
                                priorityLevel != 'High to Low'
                            ? Theme.of(context).textTheme.bodyMedium?.color
                            : Theme.of(context).primaryColor),
                    onPressed: () {
                      // Functionality to show the filter and other options as a modal bottom sheet
                      showAdaptiveDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog.adaptive(
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              title: const Text('Filters'),
                              titleTextStyle: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 8),
                              content: StatefulBuilder(builder:
                                  (BuildContext context, StateSetter setState) {
                                return SingleChildScrollView(
                                  child: SizedBox(
                                    height: 480,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Radio buttons for the date filter
                                        // Today button
                                        ListTile(
                                          dense: true,
                                          minVerticalPadding: 0,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 4),
                                          leading: Radio.adaptive(
                                              value: 'Today',
                                              groupValue: sortValue,
                                              onChanged: (String? sortvalue) {
                                                setState(() {
                                                  sortValue = sortvalue!;
                                                });
                                                stateUpdate();
                                              }),
                                          horizontalTitleGap: 0,
                                          title: Text(
                                            'Today',
                                            textAlign: TextAlign.start,
                                          ),
                                          subtitle: Text(
                                              'Show only the tasks for today'),
                                          titleTextStyle: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color),
                                          subtitleTextStyle:
                                              TextStyle(color: Colors.grey),
                                          onTap: () {
                                            setState(() {
                                              sortValue = 'Today';
                                            });
                                            stateUpdate();
                                          },
                                        ),
                                        // Recent button
                                        ListTile(
                                          dense: true,
                                          minVerticalPadding: 0,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 4),
                                          leading: Radio.adaptive(
                                              value: 'Recent tasks',
                                              groupValue: sortValue,
                                              onChanged: (String? sortvalue) {
                                                setState(() {
                                                  sortValue = sortvalue!;
                                                });
                                                stateUpdate();
                                              }),
                                          horizontalTitleGap: 0,
                                          title: Text(
                                            'Recent',
                                            textAlign: TextAlign.start,
                                          ),
                                          subtitle: Text(
                                              'Sort the tasks from recent to oldest'),
                                          titleTextStyle: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color),
                                          subtitleTextStyle:
                                              TextStyle(color: Colors.grey),
                                          onTap: () {
                                            setState(() {
                                              sortValue = 'Recent tasks';
                                            });
                                            stateUpdate();
                                          },
                                        ),
                                        // Oldest button
                                        ListTile(
                                          dense: true,
                                          minVerticalPadding: 0,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 4),
                                          leading: Radio.adaptive(
                                              value: 'oldest',
                                              groupValue: sortValue,
                                              onChanged: (String? sortvalue) {
                                                setState(() {
                                                  sortValue = sortvalue!;
                                                });
                                                stateUpdate();
                                              }),
                                          horizontalTitleGap: 0,
                                          title: Text(
                                            'Oldest',
                                            textAlign: TextAlign.start,
                                          ),
                                          subtitle: Text(
                                              'Sort the tasks from oldest to recent'),
                                          titleTextStyle: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color),
                                          subtitleTextStyle:
                                              TextStyle(color: Colors.grey),
                                          onTap: () {
                                            setState(() {
                                              sortValue = 'oldest';
                                            });
                                            stateUpdate();
                                          },
                                        ),
                                        Divider(
                                          color: Colors.grey,
                                        ),
                                        // Radio buttons for the completion filter
                                        // Incomplete button
                                        ListTile(
                                          dense: true,
                                          minVerticalPadding: 0,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 4),
                                          leading: Radio.adaptive(
                                              value: 'Incomplete',
                                              groupValue: completedSortValue,
                                              onChanged: (String? sortvalue) {
                                                setState(() {
                                                  completedSortValue =
                                                      sortvalue!;
                                                });
                                                stateUpdate();
                                              }),
                                          horizontalTitleGap: 0,
                                          title: Text(
                                            'Incomplete',
                                            textAlign: TextAlign.start,
                                          ),
                                          subtitle: Text(
                                              'Show only incomplete tasks'),
                                          titleTextStyle: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color),
                                          subtitleTextStyle:
                                              TextStyle(color: Colors.grey),
                                          onTap: () {
                                            setState(() {
                                              completedSortValue = 'Incomplete';
                                            });
                                            stateUpdate();
                                          },
                                        ),
                                        // Oldest button
                                        ListTile(
                                          dense: true,
                                          minVerticalPadding: 0,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 4),
                                          leading: Radio.adaptive(
                                              value: 'Completed',
                                              groupValue: completedSortValue,
                                              onChanged: (String? sortvalue) {
                                                setState(() {
                                                  completedSortValue =
                                                      sortvalue!;
                                                });
                                                stateUpdate();
                                              }),
                                          horizontalTitleGap: 0,
                                          title: Text(
                                            'Completed',
                                            textAlign: TextAlign.start,
                                          ),
                                          subtitle:
                                              Text('Show only completed tasks'),
                                          titleTextStyle: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color),
                                          subtitleTextStyle:
                                              TextStyle(color: Colors.grey),
                                          onTap: () {
                                            setState(() {
                                              completedSortValue = 'Completed';
                                            });
                                            stateUpdate();
                                          },
                                        ),
                                        Divider(
                                          color: Colors.grey,
                                        ),
                                        // Radio buttons for the priority filter
                                        // High to low button
                                        ListTile(
                                          dense: true,
                                          minVerticalPadding: 0,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 4),
                                          leading: Radio.adaptive(
                                              value: 'High to Low',
                                              groupValue: priorityLevel,
                                              onChanged: (String? sortvalue) {
                                                setState(() {
                                                  priorityLevel = sortvalue!;
                                                });
                                                stateUpdate();
                                              }),
                                          horizontalTitleGap: 0,
                                          title: Text(
                                            'High',
                                            textAlign: TextAlign.start,
                                          ),
                                          subtitle: Text(
                                              'Show tasks with high priority first'),
                                          titleTextStyle: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color),
                                          subtitleTextStyle:
                                              TextStyle(color: Colors.grey),
                                          onTap: () {
                                            setState(() {
                                              priorityLevel = 'High to Low';
                                            });
                                            stateUpdate();
                                          },
                                        ),
                                        // Oldest button
                                        ListTile(
                                          dense: true,
                                          minVerticalPadding: 0,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 4),
                                          leading: Radio.adaptive(
                                              value: 'Low to High',
                                              groupValue: priorityLevel,
                                              onChanged: (String? sortvalue) {
                                                setState(() {
                                                  priorityLevel = sortvalue!;
                                                });
                                                stateUpdate();
                                              }),
                                          horizontalTitleGap: 0,
                                          title: Text(
                                            'Low',
                                            textAlign: TextAlign.start,
                                          ),
                                          subtitle: Text(
                                              'Show tasks with low priority first'),
                                          titleTextStyle: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color),
                                          subtitleTextStyle:
                                              TextStyle(color: Colors.grey),
                                          onTap: () {
                                            setState(() {
                                              priorityLevel = 'Low to High';
                                            });
                                            stateUpdate();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              actions: [
                                // Cancel button
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    return;
                                  },
                                  child: Text('Cancel'),
                                ),
                              ],
                            );
                          });
                    },
                    avatar: Icon(sortValue != 'Recent tasks' ||
                            completedSortValue != 'Incomplete' ||
                            priorityLevel != 'High to Low'
                        ? Icons.check_rounded
                        : Icons.filter_list_rounded),
                    label: Text('Filter'),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            StreamBuilder<QuerySnapshot>(
                stream: fetchTasks(sortValue),
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
                    ).animate().fade(delay: const Duration(milliseconds: 50));
                  }
                  if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      width: MediaQuery.of(context).size.width,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 14.0, right: 14.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image(
                              height: 200,
                              width: 200,
                              image: AssetImage(
                                  'assets/images/allCompletedBackground.png'),
                            ),
                            Text(
                              'Hooray! Completed all your tasks',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
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
                      )
                          .animate()
                          .fade(delay: const Duration(milliseconds: 100)),
                    );
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('There was an error trying to fetch tasks.'),
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
                        return TaskTile(
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
                        );
                      },
                    ),
                  );
                }),
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
