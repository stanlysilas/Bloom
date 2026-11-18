import 'package:bloom/core/responsive/dimensions.dart';
import 'package:bloom/features/objects/notes/note_layout.dart';
import 'package:bloom/features/goals/events/screens/event_details_screen.dart';
import 'package:bloom/features/goals/habits/screens/habits_details_screen.dart';
import 'package:bloom/features/goals/tasks/screens/task_details_screen.dart';
import 'package:bloom/models/note_model.dart';
import 'package:bloom/models/task_model.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CalendarViewScreen extends StatefulWidget {
  final DateTime initialDay;
  const CalendarViewScreen({super.key, required this.initialDay});

  @override
  State<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  // Required variables for calendarviewscreen
  final user = FirebaseAuth.instance.currentUser;
  final firestore = FirebaseFirestore.instance;
  final calendarViewEventController = EventController();
  late ValueNotifier<DateTime> selectedDateNotifier;
  late String? eventsColorCode;
  late String? tasksColorCode;
  late String? entriesColorCode;
  late String? habitsColorCode;
  bool isLoadingEvents = true;
  List<CalendarEventData> allEvents = [];
  Color eventsColor = Colors.amber;
  Color tasksColor = Colors.blue;
  Color entriesColor = Colors.green;
  Color habitsColor = Colors.purple;

  // Init method for initializing variables and methods
  @override
  void initState() {
    super.initState();
    selectedDateNotifier = ValueNotifier<DateTime>(widget.initialDay);
    loadAllEvents(); // Call the loadAllEvents method to load them when the page is shown
    loadColorPreferences();
  }

  // Load the color preferences of the user for each object from firebase
  Future<void> loadColorPreferences() async {
    final doc = await firestore.collection('users').doc(user?.uid).get();
    final data = doc.data();

    if (data == null) return;

    setState(() {
      if (data['eventsColorCode'] != null) {
        eventsColorCode = data['eventsColorCode'];
        eventsColor =
            Color(int.parse(eventsColorCode!, radix: 16) + 0xFF000000);
      }
      if (data['tasksColorCode'] != null) {
        tasksColorCode = data['tasksColorCode'];
        tasksColor = Color(int.parse(tasksColorCode!, radix: 16) + 0xFF000000);
      }
      if (data['entriesColorCode'] != null) {
        entriesColorCode = data['entriesColorCode'];
        entriesColor =
            Color(int.parse(entriesColorCode!, radix: 16) + 0xFF000000);
      }
      if (data['habitsColorCode'] != null) {
        habitsColorCode = data['habitsColorCode'];
        habitsColor =
            Color(int.parse(habitsColorCode!, radix: 16) + 0xFF000000);
      }
    });
  }

  // Load all the objects from Firebase to display them together in the CalendarView
  Future<void> loadAllEvents() async {
    allEvents.clear(); // Clear the List to avoid redundancy

    // Load Events
    final eventDocs = await firestore
        .collection('users')
        .doc(user?.uid)
        .collection('events')
        .where('eventStartDateTime',
            isGreaterThanOrEqualTo: DateTime(
                selectedDateNotifier.value.year,
                selectedDateNotifier.value.month,
                selectedDateNotifier.value.day,
                0,
                0,
                0))
        .get();
    for (var doc in eventDocs.docs) {
      final data = doc.data();
      final Timestamp startTimestamp = data['eventStartDateTime'];
      final Timestamp endTimestamp = data['eventEndDateTime'];
      final String eventId = data['eventId'];
      allEvents.add(
        CalendarEventData(
            startTime: startTimestamp.toDate(),
            endTime: endTimestamp.toDate(),
            date: startTimestamp.toDate(),
            endDate: endTimestamp.toDate(),
            title: data['eventName'],
            event: {...data, 'type': 'events', 'uid': eventId},
            color: eventsColor),
      );
      setState(() {
        isLoadingEvents = true;
      });
    }

    // Other for collections with only startDate
    Future<void> loadOtherCollection(
        String collectionName, String titleFieldName, Color color) async {
      final docs = await firestore
          .collection('users')
          .doc(user?.uid)
          .collection(collectionName)
          .where('addedOn',
              isGreaterThanOrEqualTo: DateTime(
                  selectedDateNotifier.value.year,
                  selectedDateNotifier.value.month,
                  selectedDateNotifier.value.day,
                  0,
                  0,
                  0))
          .get();
      for (var doc in docs.docs) {
        final data = doc.data();
        final Timestamp timestamp = data['addedOn'];
        var uid;
        var description;
        if (collectionName == 'tasks') {
          uid = data['taskId'];
          description = data['taskNotes'];
        } else if (collectionName == 'events') {
          uid = data['eventId'];
          description = data['eventNotes'];
        } else if (collectionName == 'entries') {
          uid = data['mainEntryId'];
          description = data['mainEntryDescription'];
        } else if (collectionName == 'habits') {
          uid = data['habitId'];
          description = data['habitNotes'];
        }
        final endTime = DateTime(
            timestamp.toDate().year,
            timestamp.toDate().month,
            timestamp.toDate().day,
            timestamp.toDate().hour + 1,
            timestamp.toDate().minute,
            timestamp.toDate().second);
        allEvents.add(
          CalendarEventData(
            startTime: timestamp.toDate(),
            endTime: endTime,
            date: timestamp.toDate(),
            endDate: endTime,
            title: data[titleFieldName],
            description: description,
            event: {...data, 'type': collectionName, 'uid': uid},
            color: color,
          ),
        );
      }
      setState(() {
        isLoadingEvents = true;
      });
    }

    // Load tasks, entries, habits
    await loadOtherCollection('tasks', 'taskName', tasksColor);
    await loadOtherCollection('entries', 'mainEntryTitle', entriesColor);
    await loadOtherCollection('habits', 'habitName', habitsColor);

    // Finally, add all events
    calendarViewEventController.addAll(allEvents);
    setState(() {
      isLoadingEvents = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
          valueListenable: selectedDateNotifier,
          builder: (context, date, _) {
            return Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: MediaQuery.of(context).size.width > mobileWidth
                    ? 650
                    : null,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: DayView(
                        controller: calendarViewEventController,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        headerStyle: HeaderStyle(
                            headerPadding: EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .appBarTheme
                                    .backgroundColor),
                            titleAlign: TextAlign.left,
                            headerTextStyle: TextStyle(
                                fontFamily: 'ClashGrotesk',
                                fontWeight: FontWeight.w500,
                                fontSize: 18),
                            rightIconConfig: IconDataConfig(
                              icon: (context) {
                                return Row(
                                  children: [
                                    // Loading indicator for the CalendarEvents
                                    if (isLoadingEvents == true)
                                      CircularProgressIndicator(
                                        year2023: false,
                                        constraints: BoxConstraints(
                                            minHeight: 28,
                                            minWidth: 28,
                                            maxHeight: 28,
                                            maxWidth: 28),
                                      ),
                                    // Button for more options
                                    // PopupMenuButton(
                                    //   color: Theme.of(context).primaryColorLight,
                                    //   popUpAnimationStyle: AnimationStyle(
                                    //       duration: const Duration(milliseconds: 500)),
                                    //   itemBuilder: (context) => [
                                    //     PopupMenuItem(
                                    //       value: 'change_colors',
                                    //       child: Text(
                                    //         'Change colors',
                                    //         style: TextStyle(
                                    //             color: Theme.of(context)
                                    //                 .textTheme
                                    //                 .bodyMedium
                                    //                 ?.color),
                                    //       ),
                                    //       onTap: () async {
                                    //         // Navigate to settings screen to change the color preferences of the user in CalendarView
                                    //         Navigator.of(context).push(MaterialPageRoute(
                                    //             builder: (context) => SettingsPage()));
                                    //       },
                                    //     ),
                                    //   ],
                                    // ),
                                  ],
                                );
                              },
                            )),
                        minDay: DateTime(2000),
                        maxDay: DateTime(2101),
                        initialDay: selectedDateNotifier.value,
                        heightPerMinute: 1,
                        eventArranger: SideEventArranger(includeEdges: true),
                        keepScrollOffset: true,
                        eventTileBuilder: (date, events, boundary,
                            startDuration, endDuration) {
                          // Show all events stacked vertically if there are multiple on the same slot
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: events.map((event) {
                              final eventColor = event.color;
                              final title = event.title;
                              final Map<String, dynamic> extraData =
                                  event.event as Map<String, dynamic>;
                              final String type = extraData['type'] ?? '';
                              final String objectId = extraData['uid'] ?? '';

                              return InkWell(
                                onTap: () async {
                                  if (type == 'tasks') {
                                    bool? isCompleted;
                                    int taskUniqueId = 0;
                                    List taskGroups = [];
                                    DateTime taskDateTime = DateTime.now();
                                    int priorityLevel = 3;
                                    String priorityLevelString = 'Low';
                                    DateTime addedOn = DateTime.now();
                                    String taskMode = 'MainTask';
                                    // Retrieve the Task details using the uid from events
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(user?.uid)
                                        .collection(type)
                                        .doc(objectId)
                                        .get()
                                        .then((value) {
                                      isCompleted = value['isCompleted'];
                                      taskUniqueId = value['taskUniqueId'];
                                      taskGroups = value['taskGroups'];
                                      Timestamp timestamp =
                                          value['taskDateTime'];
                                      taskDateTime = timestamp.toDate();
                                      priorityLevel = value['priorityLevel'];
                                      priorityLevelString =
                                          value['priorityLevelString'];
                                      Timestamp timeStamp = value['addedOn'];
                                      addedOn = timeStamp.toDate();
                                      taskMode = value['taskMode'];
                                    });
                                    final taskModel = TaskModel(
                                      objectId: objectId,
                                      addedOn: addedOn,
                                      name: title,
                                      description: event.description,
                                      isCompleted: isCompleted ?? false,
                                      dateTime: taskDateTime,
                                      uniqueNotificationId: taskUniqueId,
                                      groups: taskGroups as List<String>,
                                      priorityLevel: priorityLevel,
                                      priorityLevelString: priorityLevelString,
                                    );
                                    // Show a modal bottom sheet with the details of the tasks
                                    showModalBottomSheet(
                                        context: context,
                                        showDragHandle: true,
                                        isScrollControlled: true,
                                        useSafeArea: true,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        builder: (context) {
                                          return ShowTaskDetailsScreen(
                                              taskModel: taskModel);
                                        });
                                  } else if (type == 'events') {
                                    bool? isAttended;
                                    int eventUniqueId = 0;
                                    String color;
                                    Color eventColorCode =
                                        Theme.of(context).colorScheme.primary;
                                    // Retrieve the details of the event from FirebaseFirestore
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(user?.uid)
                                        .collection(type)
                                        .doc(objectId)
                                        .get()
                                        .then((value) {
                                      isAttended = value['isAttended'];
                                      eventUniqueId = value['eventUniqueId'];
                                      color = value['eventColorCode'];
                                      eventColorCode = Color(
                                          int.parse(color, radix: 16) +
                                              0xFF000000);
                                    });
                                    // Show a modal bottom sheet with the details of the events
                                    showModalBottomSheet(
                                        context: context,
                                        showDragHandle: true,
                                        isScrollControlled: true,
                                        useSafeArea: true,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        builder: (context) {
                                          return EventDetailsScreen(
                                              eventName: event.title,
                                              eventNotes:
                                                  event.description ?? '',
                                              eventId: objectId,
                                              eventStartDateTime:
                                                  event.startTime!,
                                              eventEndDateTime: event.endTime,
                                              eventColorCode: eventColorCode,
                                              eventUniqueId: eventUniqueId,
                                              appBarLeading: Icons.close,
                                              isAttended: isAttended ?? false);
                                        });
                                  } else if (type == 'entries') {
                                    bool? hasChildren;
                                    DateTime dateTime = DateTime.now();
                                    DateTime addedOn = DateTime.now();
                                    bool? isEntryLocked;
                                    String emoji = '';
                                    bool? isFavorite;
                                    String backgroundImageUrl = '';
                                    // Retrieve the details of the entry from FirebaseFirestore
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(user?.uid)
                                        .collection(type)
                                        .doc(objectId)
                                        .get()
                                        .then((value) {
                                      hasChildren = value['hasChildren'];
                                      Timestamp timestamp = value['dateTime'];
                                      Timestamp createdAt = value['addedOn'];
                                      addedOn = createdAt.toDate();
                                      dateTime = timestamp.toDate();
                                      isEntryLocked = value['isEntryLocked'];
                                      isFavorite = value['isFavorite'];
                                      emoji = value['mainEntryEmoji'];
                                      backgroundImageUrl =
                                          value['backgroundImageUrl'];
                                    });
                                    final noteModel = NoteModel(
                                        parentId: null,
                                        objectId: objectId,
                                        title: event.title,
                                        content: event.description ?? '',
                                        icon: emoji,
                                        addedOn: addedOn,
                                        dateTime: dateTime,
                                        isFavorite: isFavorite ?? false,
                                        isLocked: isEntryLocked ?? false,
                                        backgroundImageUrl: backgroundImageUrl,
                                        attachments: [],
                                        children: [],
                                        hasChildren: hasChildren ?? false,
                                        type: 'note',
                                        isSyncing: true);
                                    // Navigate to the Notes screen with the details of the entry
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            fullscreenDialog: true,
                                            barrierDismissible: true,
                                            builder: (context) => NoteLayout(
                                                  mode: NoteMode.display,
                                                  noteModel: noteModel,
                                                )));
                                  } else if (type == 'habits') {
                                    List habitGroups = [];
                                    int habitUniqueId = 0;
                                    List daysOfWeek = [];
                                    List completedDaysOfWeek = [];
                                    DateTime addedOn = DateTime.now();
                                    List completedDates = [];
                                    // Retreive the details of the habit from FirebaseFirestore
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(user?.uid)
                                        .collection(type)
                                        .doc(objectId)
                                        .get()
                                        .then((value) {
                                      habitGroups = value['habitGroups'];
                                      habitUniqueId = value['habitUniqueId'];
                                      daysOfWeek = value['daysOfWeek'];
                                      completedDaysOfWeek =
                                          value['completedDaysOfWeek'];
                                      Timestamp timestamp = value['addedOn'];
                                      addedOn = timestamp.toDate();
                                      completedDates = value['completedDates'];
                                    });
                                    // Show a modal bottom sheet with the details of the habit
                                    showModalBottomSheet(
                                        context: context,
                                        showDragHandle: true,
                                        isScrollControlled: true,
                                        useSafeArea: true,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        builder: (context) =>
                                            HabitsDetailsScreen(
                                                habitName: event.title,
                                                habitNotes:
                                                    event.description ?? '',
                                                habitDateTime: event.date,
                                                habitGroups: habitGroups,
                                                habitId: objectId,
                                                habitUniqueId: habitUniqueId,
                                                daysOfWeek: daysOfWeek,
                                                addedOn: addedOn,
                                                appBarLeading: Icons.close,
                                                completedDates:
                                                    completedDates));
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 4),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: eventColor.withAlpha(120),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    title,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                        onPageChange: (newDate, page) {
                          setState(() {
                            selectedDateNotifier.value = newDate;
                          });
                          calendarViewEventController.removeAll(
                              allEvents); // Clear the calendarViewEventController to avoid redundancy
                          loadAllEvents();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
