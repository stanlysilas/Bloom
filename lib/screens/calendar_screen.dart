// import 'package:bloom/screens/settings_screen.dart';
import 'package:bloom/responsive/dimensions.dart';
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
      allEvents.add(
        CalendarEventData(
            startTime: startTimestamp.toDate(),
            endTime: endTimestamp.toDate(),
            date: startTimestamp.toDate(),
            endDate: endTimestamp.toDate(),
            title: data['eventName'],
            event: {...data, 'type': 'events'},
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
            event: {...data, 'type': collectionName},
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: MediaQuery.of(context).size.width < mobileWidth
            ? const EdgeInsets.all(0)
            : const EdgeInsets.symmetric(horizontal: 120),
        child: ValueListenableBuilder(
            valueListenable: selectedDateNotifier,
            builder: (context, date, _) {
              return DayView(
                controller: calendarViewEventController,
                backgroundColor: Theme.of(context).colorScheme.surface,
                showHalfHours: true,
                headerStyle: HeaderStyle(
                    decoration: BoxDecoration(
                        color: Theme.of(context).appBarTheme.backgroundColor),
                    leftIconConfig: IconDataConfig(
                      icon: (context) {
                        return IconButton(
                            tooltip: 'Back',
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(Icons.arrow_back));
                      },
                    ),
                    titleAlign: TextAlign.left,
                    headerTextStyle:
                        TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
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
                eventArranger: SideEventArranger(),
                keepScrollOffset: true,
                eventTileBuilder:
                    (date, events, boundary, startDuration, endDuration) {
                  // Show all events stacked vertically if there are multiple on the same slot
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: events.map((event) {
                      final eventColor = event.color;
                      final title = event.title;

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: eventColor,
                          borderRadius: BorderRadius.circular(8),
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
              );
            }),
      ),
    );
  }
}
