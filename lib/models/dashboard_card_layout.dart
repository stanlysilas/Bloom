import 'package:bloom/components/entries_tile.dart';
import 'package:bloom/components/events_tile.dart';
import 'package:bloom/components/habit_tile.dart';
import 'package:bloom/components/tasktile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'dart:async';

class DashboardCardLayout extends StatefulWidget {
  // final int? numberOfTasks;
  // final int? numberOfSchedules;
  // final int? numberOfEntries;
  // final int? numberOfHabits;
  final DateTime focusedDay;
  const DashboardCardLayout({
    super.key,
    required this.focusedDay,
  });

  @override
  State<DashboardCardLayout> createState() => _DashboardCardLayoutState();
}

class _DashboardCardLayoutState extends State<DashboardCardLayout> {
  final user = FirebaseAuth.instance.currentUser;
  late Stream<List<QuerySnapshot>> combinedStream;
  BorderRadius borderRadius = BorderRadius.all(Radius.circular(0));

  @override
  void initState() {
    super.initState();
    _initCombinedStream();
  }

  @override
  void didUpdateWidget(covariant DashboardCardLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If focusedDay changes, rebuild the stream once
    if (oldWidget.focusedDay != widget.focusedDay) {
      _initCombinedStream();
    }
  }

  void _initCombinedStream() {
    combinedStream = combineFourStreams(
      fetchEntriesForDay(widget.focusedDay),
      fetchEvents(widget.focusedDay),
      fetchTasks(widget.focusedDay),
      fetchHabits(widget.focusedDay),
    );
  }

  Stream<QuerySnapshot> fetchEntriesForDay(DateTime date) {
    var dayStart = DateTime(widget.focusedDay.year, widget.focusedDay.month,
        widget.focusedDay.day, 0, 0, 0);
    var dayEnd = DateTime(widget.focusedDay.year, widget.focusedDay.month,
        widget.focusedDay.day, 23, 59, 59);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('entries')
        .where('dateTime', isGreaterThanOrEqualTo: dayStart)
        .where('dateTime', isLessThanOrEqualTo: dayEnd)
        .orderBy('dateTime', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> fetchEvents(DateTime date) {
    var dayStart = DateTime(date.year, date.month, date.day, 0, 0, 0);
    var dayEnd = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('events')
        .where('isAttended', isEqualTo: false)
        .where('eventStartDateTime', isGreaterThanOrEqualTo: dayStart)
        .where('eventEndDateTime', isLessThanOrEqualTo: dayEnd)
        .orderBy('eventStartDateTime', descending: true)
        .snapshots();
  }

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

  Stream<QuerySnapshot> fetchHabits(DateTime date) {
    var dayStart = DateTime(date.year, date.month, date.day, 0, 0, 0);
    var dayEnd = DateTime(date.year, date.month, date.day, 23, 59, 59);
    // var dateString = DateFormat('yyyy-MM-dd').format(date);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('habits')
        // .where('lastUpdated', isNotEqualTo: dateString)
        .where('habitDateTime', isGreaterThanOrEqualTo: dayStart)
        .where('habitDateTime', isLessThanOrEqualTo: dayEnd)
        // .orderBy('habitDateTime', descending: false)
        .snapshots();
  }

  /// Combine three streams manually (pure dart:async, no async package)
  Stream<List<QuerySnapshot>> combineFourStreams(
    Stream<QuerySnapshot> s1,
    Stream<QuerySnapshot> s2,
    Stream<QuerySnapshot> s3,
    Stream<QuerySnapshot> s4,
  ) {
    // We use a controller to merge the results
    final controller = StreamController<List<QuerySnapshot>>();

    // Latest values storage
    QuerySnapshot? last1, last2, last3, last4;

    void update() {
      // Only emit when we have at least one snapshot from each
      if (last1 != null && last2 != null && last3 != null && last4 != null) {
        controller.add([last1!, last2!, last3!, last4!]);
      }
    }

    // Subscribe to all three independently
    final sub1 = s1.listen((v) {
      last1 = v;
      update();
    });
    final sub2 = s2.listen((v) {
      last2 = v;
      update();
    });
    final sub3 = s3.listen((v) {
      last3 = v;
      update();
    });
    final sub4 = s4.listen((v) {
      last4 = v;
      update();
    });

    controller.onCancel = () {
      sub1.cancel();
      sub2.cancel();
      sub3.cancel();
      sub4.cancel();
    };

    return controller.stream;
  }

  /// Calculate the [BorderRadius] for the entry, task and event tiles
  BorderRadius calculateBorderRadius(
      int totalItems, bool isFirst, bool isLast) {
    if (totalItems == 1) {
      // Only one item exists: rounded on all corners
      borderRadius = BorderRadius.circular(16);
    } else if (isFirst) {
      // First of many: rounded top
      borderRadius = const BorderRadius.vertical(
          top: Radius.circular(16), bottom: Radius.circular(4));
    } else if (isLast) {
      // Last of many: rounded bottom
      borderRadius = const BorderRadius.vertical(
          top: Radius.circular(4), bottom: Radius.circular(16));
    } else {
      // Middle items: minimal rounding
      borderRadius = BorderRadius.circular(4);
    }
    return borderRadius;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: StreamBuilder<List<QuerySnapshot>>(
        stream: combinedStream,
        builder: (context, snapshot) {
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
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Failed to load dashboard data.'),
            );
          }

          if (!snapshot.hasData) {
            return const SizedBox();
          }

          // Order of streams = entries, events, tasks
          final entriesSnap = snapshot.data![0];
          final eventsSnap = snapshot.data![1];
          final tasksSnap = snapshot.data![2];
          final habitsSnap = snapshot.data![3];

          final entries = entriesSnap.docs;
          final events = eventsSnap.docs;
          final tasksList = tasksSnap.docs;
          final habitsList = habitsSnap.docs;
          // print(habitsList.first);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (entries.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ListView.builder(
                    itemCount: entries.length > 3 ? 3 : entries.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final int totalItems =
                          entries.length > 3 ? 3 : entries.length;
                      final bool isFirst = index == 0;
                      final bool isLast = index == totalItems - 1;
                      calculateBorderRadius(totalItems, isFirst, isLast);
                      final entry = entries[index];
                      final entryDescription =
                          entry['mainEntryDescription'] ?? '{}';
                      final entryTitle = entry['mainEntryTitle'] ?? '';
                      final entryBackgroundImageUrl =
                          entry['backgroundImageUrl'] ?? '';
                      final entryId = entry['mainEntryId'] ?? '';
                      final entryType = entry['mainEntryType'] ?? '';
                      final entryEmoji = entry['mainEntryEmoji'] ?? '';
                      final entryAttachments = entry['attachments'] ?? [];
                      final entryChildren = entry['children'];
                      final entryHasChildren = entry['hasChildren'];
                      final Timestamp timestamp = entry['addedOn'];
                      final Timestamp datetime = entry['dateTime'];
                      final DateTime entryDate = timestamp.toDate();
                      final DateTime dateTime = datetime.toDate();
                      final DateTime addedOn = entryDate;
                      final entryIsFavorite = entry['isFavorite'];
                      final date = DateFormat('dd-MM-yyyy').format(entryDate);
                      final entryTime = entry['dateTime']?.toDate() ?? '';
                      final time = DateFormat('h:mm a').format(entryTime);
                      final isSynced = entry['synced'];
                      // Fix for a bug in v1.0.1 beta-1 that caused grey screens when notes are added
                      // This is because of missing the isEntryLocked field when creating & updating new notes
                      final data = entry.data() as Map<String, dynamic>;
                      final isEntryLocked = data['isEntryLocked'] ?? false;
                      // Updating the isEntryLocked to false to avoid any errors
                      if (data['isEntryLocked'] == null) {
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(user?.uid)
                            .collection('entries')
                            .doc(entryId)
                            .set({'isEntryLocked': false},
                                SetOptions(merge: true));
                      }

                      return Column(
                        children: [
                          SizedBox(height: index != 0 ? 0 : 8),
                          EntriesTile(
                            innerPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            borderRadius: borderRadius,
                            content: entryDescription,
                            title: entryTitle,
                            emoji: entryEmoji,
                            date: date,
                            time: time,
                            id: entryId,
                            type: entryType,
                            backgroundImageUrl: entryBackgroundImageUrl,
                            attachments: entryAttachments,
                            hasChildren: entryHasChildren,
                            children: entryChildren,
                            isFavorite: entryIsFavorite ?? false,
                            addedOn: addedOn,
                            dateTime: dateTime,
                            isSynced: isSynced,
                            isEntryLocked: isEntryLocked ?? false,
                            isTemplate: false,
                          ),
                          SizedBox(height: entries.length - 1 == index ? 8 : 4),
                        ],
                      );
                    },
                  ),
                ),
              if (events.isNotEmpty) const SizedBox(height: 14),
              if (events.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ListView.builder(
                    itemCount: events.length > 3 ? 3 : events.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final int totalItems =
                          events.length > 3 ? 3 : events.length;
                      final bool isFirst = index == 0;
                      final bool isLast = index == totalItems - 1;
                      calculateBorderRadius(totalItems, isFirst, isLast);
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
                          SizedBox(height: index != 0 ? 0 : 8),
                          EventsTile(
                            innerPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            borderRadius: borderRadius,
                            eventName: eventName,
                            eventNotes: eventDetails,
                            eventStartDateTime: eventStartDateTime,
                            eventEndDateTime: eventEndDateTime,
                            eventColorCode: eventColorCode,
                            eventId: eventId,
                            eventUniqueId: eventUniqueId ?? 0,
                            isAttended: isAttended,
                          ),
                          SizedBox(height: events.length - 1 == index ? 8 : 4),
                        ],
                      );
                    },
                  ),
                ),
              if (tasksList.isNotEmpty) const SizedBox(height: 14),
              if (tasksList.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ListView.builder(
                    itemCount: tasksList.length > 3 ? 3 : tasksList.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final int totalItems =
                          tasksList.length > 3 ? 3 : tasksList.length;
                      final bool isFirst = index == 0;
                      final bool isLast = index == totalItems - 1;
                      calculateBorderRadius(totalItems, isFirst, isLast);
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

                      return Column(
                        children: [
                          SizedBox(height: index != 0 ? 0 : 8),
                          TaskTile(
                            innerPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            borderRadius: borderRadius,
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
                          ),
                          SizedBox(
                              height: tasksList.length - 1 == index ? 8 : 4),
                        ],
                      );
                    },
                  ),
                ),
              if (habitsList.isNotEmpty) const SizedBox(height: 14),
              if (habitsList.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: habitsList.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = habitsList[index];
                      String habitId = document.id;
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      String habitName = data['habitName'];
                      String habitNotes = data['habitNotes'];
                      int habitUniqueId = data['habitUniqueId'] ?? 0;
                      Timestamp timestamp = data['habitDateTime'];
                      List daysOfWeek = data['daysOfWeek'] ?? [];
                      List completedDaysOfWeek =
                          data['completedDaysOfWeek'] ?? [];
                      List completedDates = data['completedDates'] ?? [];
                      DateTime habitDateTime = timestamp.toDate();
                      List habitGroups = data['habitGroups'];
                      Timestamp timeStamp = data['addedOn'];
                      int bestStreak = data['bestStreak'] ?? 0;
                      int currentStreak = data['currentStreak'] ?? 0;
                      DateTime addedOn = timeStamp.toDate();
                      return Column(
                        children: [
                          SizedBox(height: index != 0 ? 0 : 8),
                          HabitTile(
                            margin: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            innerPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            habitId: habitId,
                            habitName: habitName,
                            habitNotes: habitNotes,
                            habitDateTime: habitDateTime,
                            habitGroups: habitGroups,
                            daysOfWeek: daysOfWeek,
                            completedDaysOfWeek: completedDaysOfWeek,
                            addedOn: addedOn,
                            habitUniqueId: habitUniqueId,
                            completedDates: completedDates,
                            bestStreak: bestStreak,
                            currentStreak: currentStreak,
                          ),
                          SizedBox(
                              height: habitsList.length - 1 == index ? 8 : 4),
                        ],
                      );
                    },
                  ),
                )
            ],
          );
        },
      ),
    );
  }
}
