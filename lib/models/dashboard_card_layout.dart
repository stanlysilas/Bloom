import 'package:bloom/components/events_tile.dart';
import 'package:bloom/components/tasktile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DashboardCardLayout extends StatefulWidget {
  final int? numberOfTasks;
  final int? numberOfSchedules;
  final DateTime focusedDay;
  const DashboardCardLayout(
      {super.key,
      required this.numberOfTasks,
      required this.numberOfSchedules,
      required this.focusedDay});

  @override
  State<DashboardCardLayout> createState() => _DashboardCardLayoutState();
}

class _DashboardCardLayoutState extends State<DashboardCardLayout> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    fetchEvents(widget.focusedDay);
    fetchTasks(widget.focusedDay);
  }

  // Method to retrieve the documents of events collection to display them
  Stream<QuerySnapshot> fetchEvents(DateTime date) {
    var dayStart = DateTime(date.year, date.month, date.day, 0, 0, 0);
    // var dayEnd = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('events')
        .where('isAttended', isEqualTo: false)
        .where('eventStartDateTime', isGreaterThanOrEqualTo: dayStart)
        .orderBy('eventStartDateTime', descending: true)
        .snapshots();
  }

  // Method to retrieve the documents of tasks collection to display them
  Stream<QuerySnapshot> fetchTasks(DateTime date) {
    var dayStart = DateTime(date.year, date.month, date.day, 0, 0, 0);
    var dayEnd = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('tasks')
        .where('isCompleted', isEqualTo: false)
        .where('taskDateTime', isGreaterThanOrEqualTo: dayStart)
        .where('taskDateTime', isLessThanOrEqualTo: dayEnd)
        .orderBy('taskDateTime', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Upcoming events are displayed here
        widget.numberOfSchedules == 0
            ? const SizedBox()
            : StreamBuilder(
                stream: fetchEvents(widget.focusedDay),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                    return const SizedBox();
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Skeletonizer(
                      enabled: true,
                      containersColor: Theme.of(context).primaryColorDark,
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
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('There was an error trying to fetch events.'),
                    );
                  }
                  final events = snapshot.data!.docs;
                  return ListView.builder(
                      itemCount: events.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final eventDoc = events[index];
                        final eventName = eventDoc['eventName'];
                        final eventDetails = eventDoc['eventNotes'];
                        final Timestamp endDateTime =
                            eventDoc['eventEndDateTime'];
                        final DateTime eventEndDateTime = endDateTime.toDate();
                        final Timestamp startDateTime =
                            eventDoc['eventStartDateTime'];
                        final DateTime eventStartDateTime =
                            startDateTime.toDate();
                        final String color = eventDoc['eventColorCode'];
                        final Color eventColorCode =
                            Color(int.parse(color, radix: 16) + 0xFF000000);
                        final eventId = eventDoc['eventId'];
                        final int? eventUniqueId = eventDoc['eventUniqueId'];
                        final bool isAttended = eventDoc['isAttended'] ?? false;
                        return Column(
                          children: [
                            EventsTile(
                              innerPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 4),
                              eventName: eventName,
                              eventNotes: eventDetails,
                              eventStartDateTime: eventStartDateTime,
                              eventEndDateTime: eventEndDateTime,
                              eventColorCode: eventColorCode,
                              eventId: eventId,
                              eventUniqueId: eventUniqueId ?? 0,
                              isAttended: isAttended,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              child: const Divider().animate().fade(
                                  delay: const Duration(milliseconds: 250)),
                            )
                          ],
                        );
                      });
                },
              ),
        // Recent tasks and habits area
        widget.numberOfTasks == 0
            ? const SizedBox()
            : StreamBuilder<QuerySnapshot>(
                stream: fetchTasks(widget.focusedDay),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Skeletonizer(
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
                    ).animate().fade(delay: const Duration(milliseconds: 50));
                  }
                  if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                    return const SizedBox();
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('There was an error trying to fetch tasks.'),
                    );
                  }
                  List tasksList = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: tasksList.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = tasksList[index];
                      String docId = document.id;
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      String taskName = data['taskName'];
                      String taskNotes = data['taskNotes'];
                      int taskUniqueId = data['taskUniqueId'] ?? 0;
                      bool isCompleted = data['isCompleted'];
                      Timestamp timestamp = data['taskDateTime'];
                      List taskGroups = data['taskGroups'];
                      String taskGroupNames = taskGroups.join(',');
                      Timestamp timeStamp = data['addedOn'];
                      int priorityLevel = data['priorityLevel'];
                      DateTime taskDateTime = timestamp.toDate();
                      DateTime addedOn = timeStamp.toDate();
                      String priorityLevelString = data['priorityLevelString'];
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
                            taskId: docId,
                            taskUniqueId: taskUniqueId,
                            taskGroup: taskGroupNames,
                            taskGroups: [taskGroups],
                            taskDateTime: taskDateTime,
                            priorityLevel: priorityLevel,
                            priorityLevelString: priorityLevelString,
                            addedOn: addedOn,
                            taskMode: taskMode,
                            isHabit: isHabit,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 14.0),
                            child: const Divider()
                                .animate()
                                .fade(delay: const Duration(milliseconds: 250)),
                          )
                        ],
                      );
                    },
                  );
                }),
      ],
    );
  }
}
