import 'dart:io';

import 'package:bloom/components/add_event.dart';
import 'package:bloom/components/events_tile.dart';
import 'package:bloom/components/mytextfield.dart';
import 'package:bloom/required_data/colors.dart';
import 'package:calendar_view/calendar_view.dart' as cv;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:table_calendar/table_calendar.dart' as tc;

class SchedulesScreen extends StatefulWidget {
  const SchedulesScreen({super.key});

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  // Required variables
  final user = FirebaseAuth.instance.currentUser;
  tc.CalendarFormat _calendarFormat = tc.CalendarFormat.week;
  final eventController = cv.EventController();
  late TextEditingController searchController;
  var _focusedDay = DateTime.now();
  var _selectedDay = DateTime.now();
  bool toggleDayView = false;
  bool toggleSearch = false;
  List<DocumentSnapshot> searchResults = [];
  late BannerAd bannerAd;
  bool isAdLoaded = false;

  // Method to initialize the required variables and methods
  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    searchController.addListener(onSearchChanged);
    fetchEventsForCalendar();
    fetchAndSetEventsForDay(_focusedDay);
    // initBannerAd();
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  void onSearchChanged() {
    searchFirestore(searchController.text);
  }

  Future searchFirestore(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return searchResults;
    }

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users') // Change to your collection name
        .doc(user?.uid)
        .collection('events')
        .where('eventName', isGreaterThanOrEqualTo: query)
        .where('eventName', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    setState(() {
      searchResults = snapshot.docs;
    });
  }

  Stream<QuerySnapshot> fetchEventsForDay(DateTime date) {
    var dayStart =
        DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day, 0, 0, 0);
    // var dayEnd = DateTime(
    //     _focusedDay.year, _focusedDay.month, _focusedDay.day, 23, 59, 59);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('events')
        .where('eventStartDateTime', isGreaterThanOrEqualTo: dayStart)
        .where('isAttended', isEqualTo: false)
        // .where('eventStartDateTime', isLessThanOrEqualTo: dayEnd)
        .orderBy('eventStartDateTime', descending: true)
        .snapshots();
  }

  Map<DateTime, List<Event>> _events = {};

  Future<void> fetchEventsForCalendar() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('events')
        .where('isAttended', isEqualTo: false)
        .get();

    Map<DateTime, List<Event>> events = {};

    for (var doc in snapshot.docs) {
      Timestamp timestamp = doc['eventStartDateTime'];
      DateTime dateTime = timestamp.toDate();
      DateTime date = normalizeDate(dateTime);
      Event event = Event(
        id: doc.id,
        title: doc['eventName'],
        description: doc['eventNotes'],
      );

      // Group events by date
      if (events[date] == null) {
        events[date] = [];
      }
      events[date]!.add(event);
    }

    setState(() {
      _events = events;
    });
  }

  DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day, 0, 0, 0);
  }

  List<cv.CalendarEventData> dayEvents = [];

  Future<void> fetchAndSetEventsForDay(DateTime day) async {
    // Normalize the date to match Firebase data
    DateTime normalizedDay = DateTime(
        day.year, day.month, day.day, day.hour, day.minute, day.second);

    // Fetch events from Firebase
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('events')
        .where('isAttended', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      Timestamp startTimestamp = doc['eventStartDateTime'];
      DateTime eventStartDateTime = startTimestamp.toDate();
      Timestamp endTimestamp = doc['eventEndDateTime'];
      DateTime eventEndDateTime = endTimestamp.toDate();
      String colorCode = doc['eventColorCode'];
      Color eventColorCode = Color(int.parse("0xff$colorCode"));
      if (eventStartDateTime.year == normalizedDay.year &&
          eventStartDateTime.month == normalizedDay.month &&
          eventStartDateTime.day == normalizedDay.day) {
        // Add event to the list
        dayEvents.add(
          cv.CalendarEventData(
              title: doc['eventName'],
              description: doc['eventNotes'],
              date: eventStartDateTime,
              endDate: eventEndDateTime,
              color: eventColorCode,
              startTime: eventStartDateTime,
              endTime: eventEndDateTime,
              event: doc['eventName'],
              titleStyle: TextStyle(
                overflow: TextOverflow.ellipsis,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              descriptionStyle:
                  const TextStyle(overflow: TextOverflow.ellipsis)),
        );
      }
    }

    // Update the event controller
    setState(() {
      eventController.addAll(dayEvents);
    });
  }

  // Banner ADs initialization method
  initBannerAd() {
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: "ca-app-pub-5607290715305671/6637822895",
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              margin: const EdgeInsets.all(6),
              behavior: SnackBarBehavior.floating,
              showCloseIcon: true,
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              content: Text(
                'Failed to load the Ad. ${error.message}',
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color),
              )));
        },
      ),
      request: const AdRequest(),
    );

    bannerAd.load();
  }

  @override
  void dispose() {
    searchController.removeListener(onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: toggleDayView
            ? Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final focusedDay = await showDatePicker(
                        context: context,
                        firstDate: DateTime.utc(2010, 10, 16),
                        lastDate: DateTime.utc(2030, 3, 14),
                        initialDate: _focusedDay,
                        currentDate: _selectedDay,
                      );
                      onDaySelected(
                          focusedDay ?? _focusedDay, focusedDay ?? _focusedDay);
                      fetchAndSetEventsForDay(focusedDay!);
                    },
                    child: Row(
                      children: [
                        Text(
                          DateFormat('LLL d, yy').format(_focusedDay),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const Icon(
                          Icons.arrow_drop_down_rounded,
                          size: 36,
                        ),
                      ],
                    ),
                  ),
                  const Spacer()
                ],
              ).animate().fadeIn(
                  duration: const Duration(milliseconds: 700),
                )
            : const Text(
                'Schedules',
                style: TextStyle(fontWeight: FontWeight.w500),
              ).animate().fadeIn(
                  duration: const Duration(milliseconds: 700),
                ),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  // Set search to true
                  toggleSearch = !toggleSearch;
                });
                toggleSearch == false
                    ? searchController.clear()
                    : searchController.text;
              },
              icon: const Icon(Icons.search)),
          IconButton(
            onPressed: () {
              setState(() {
                toggleDayView = !toggleDayView;
              });
            },
            icon: toggleDayView
                ? const Icon(Iconsax.calendar_1).animate().fadeIn(
                      duration: const Duration(milliseconds: 500),
                    )
                : const Icon(Icons.calendar_view_day_outlined).animate().fadeIn(
                      duration: const Duration(milliseconds: 500),
                    ),
          ),
        ],
      ),
      body: SafeArea(
        child: toggleSearch
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: MyTextfield(
                      controller: searchController,
                      hintText: 'Search (Case Sensitive)',
                      obscureText: false,
                      textInputType: TextInputType.text,
                      autoFocus: false,
                    ).animate().fadeIn(
                          duration: const Duration(milliseconds: 500),
                        ),
                  ),
                  searchResults.isEmpty && searchController.text.isEmpty
                      ? const Expanded(
                          child: Center(
                              child: Padding(
                            padding: EdgeInsets.only(left: 14.0, right: 14.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Enter the name of an event to search for it. Searches are case sensitive.',
                                  style: TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  "Eg: If an event name is 'Event name', then it won't be shown if you search 'event name'",
                                  style: TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )),
                        )
                      : searchResults.isEmpty
                          ? const Expanded(
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 16.0, horizontal: 14),
                                  child: Text(
                                    'No matching results',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            )
                          : const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 14),
                              child: Text(
                                'Showing matching results',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ).animate().fadeIn(
                                duration: const Duration(milliseconds: 500),
                              ),
                  Expanded(
                    child: ListView.builder(
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              final tasksList = searchResults[index];
                              final doc = tasksList;
                              final eventTitle = doc['eventName'];
                              final eventDetails = doc['eventNotes'];
                              final Timestamp endDateTime =
                                  doc['eventEndDateTime'];
                              final DateTime eventEndDateTime =
                                  endDateTime.toDate();
                              final Timestamp startDateTime =
                                  doc['eventStartDateTime'];
                              final DateTime eventStartDateTime =
                                  startDateTime.toDate();
                              final eventId = doc['eventId'];
                              final String color = doc['eventColorCode'];
                              final int? eventUniqueId = doc['eventUniqueId'];
                              final Color eventColorCode = Color(
                                  int.parse(color, radix: 16) + 0xFF000000);
                              final bool isAttended =
                                  doc['isAttended'] ?? false;
                              if (searchResults.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'There is no matching data',
                                  ),
                                );
                              } else {
                                return Column(
                                  children: [
                                    EventsTile(
                                      innerPadding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 4),
                                      eventId: eventId,
                                      eventStartDateTime: eventStartDateTime,
                                      eventName: eventTitle,
                                      eventNotes: eventDetails ?? '',
                                      eventEndDateTime: eventEndDateTime,
                                      eventColorCode: eventColorCode,
                                      eventUniqueId: eventUniqueId ?? 0,
                                      isAttended: isAttended,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14.0),
                                      child: const Divider().animate().fade(
                                          delay: const Duration(
                                              milliseconds: 250)),
                                    )
                                  ],
                                );
                              }
                            }).animate().fadeIn(
                          duration: const Duration(milliseconds: 500),
                        ),
                  ),
                ],
              )
            : toggleDayView
                // This is the full day view
                ? cv.DayView(
                    controller: eventController,
                    eventTileBuilder:
                        (date, events, boundary, startDuration, endDuration) {
                      return ListView.builder(
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: event.color,
                            ),
                            child: Text(
                              event.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    pageTransitionCurve: Curves.easeInBack,
                    pageTransitionDuration: const Duration(milliseconds: 700),
                    dayTitleBuilder: cv.DayHeader.hidden,
                    keepScrollOffset: true,
                    minDay: DateTime.utc(2010, 10, 16),
                    maxDay: DateTime.utc(2030, 3, 14),
                    initialDay: _focusedDay,
                    onPageChange: (date, page) {
                      onDaySelected(date, date);
                      dayEvents.clear();
                      fetchAndSetEventsForDay(date);
                    },
                  ).animate().fadeIn(
                      duration: const Duration(milliseconds: 500),
                    )
                : SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display the calendar at top
                        tc.TableCalendar(
                          pageAnimationCurve: Curves.easeInBack,
                          pageAnimationDuration:
                              const Duration(milliseconds: 500),
                          formatAnimationCurve: Curves.easeInOut,
                          formatAnimationDuration:
                              const Duration(milliseconds: 500),
                          focusedDay: _focusedDay,
                          firstDay: DateTime.utc(2010, 10, 16),
                          lastDay: DateTime.utc(2030, 3, 14),
                          selectedDayPredicate: (day) {
                            return tc.isSameDay(_selectedDay, day);
                          },
                          headerStyle: tc.HeaderStyle(
                            titleTextStyle: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 17),
                            formatButtonTextStyle: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                            formatButtonDecoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                          ),
                          daysOfWeekStyle: const tc.DaysOfWeekStyle(
                              weekdayStyle:
                                  TextStyle(fontWeight: FontWeight.w500)),
                          calendarStyle: tc.CalendarStyle(
                            todayDecoration: const BoxDecoration(
                              color: secondaryColorLightMode,
                              shape: BoxShape.circle,
                            ),
                            todayTextStyle: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color),
                            selectedDecoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            selectedTextStyle: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.color),
                            weekendTextStyle: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                            ),
                            markerDecoration: const BoxDecoration(
                              color: secondaryColorLightMode,
                              shape: BoxShape.circle,
                            ),
                            markersAlignment: Alignment.bottomCenter,
                          ),
                          availableCalendarFormats: const {
                            tc.CalendarFormat.month: 'Week',
                            tc.CalendarFormat.twoWeeks: 'Month',
                            tc.CalendarFormat.week: '2 Weeks',
                          },
                          calendarFormat: _calendarFormat,
                          onFormatChanged: (format) {
                            setState(() {
                              _calendarFormat = format;
                            });
                          },
                          eventLoader: (day) {
                            // Return the list of events for the given day
                            return _events[normalizeDate(day)] ?? [];
                          },
                          onDaySelected: (selectedDay, focusedDay) {
                            onDaySelected(selectedDay, focusedDay);
                            fetchAndSetEventsForDay(focusedDay);
                          },
                        ).animate().fadeIn(
                              duration: const Duration(
                                milliseconds: 500,
                              ),
                            ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Divider(),
                        ),
                        // Display the tasks matching to the selected or focused day
                        StreamBuilder<QuerySnapshot>(
                          stream: fetchEventsForDay(_focusedDay),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
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
                              ).animate().fade(
                                  delay: const Duration(milliseconds: 50));
                            }
                            if (snapshot.hasData &&
                                snapshot.data!.docs.isEmpty) {
                              return SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                width: MediaQuery.of(context).size.width,
                                child: const Padding(
                                  padding:
                                      EdgeInsets.only(left: 14.0, right: 14.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Image(
                                          image: AssetImage(
                                              'assets/images/eventsCompletedBackground.png'),
                                        ),
                                      ),
                                      Text(
                                        'Finally! Attended your events',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        'Take your most deserved holiday now',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ).animate().fadeIn(
                                    delay: const Duration(milliseconds: 100),
                                  );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                    'Encountered an error while retrieving events for ${DateFormat.yMMMMd().format(_focusedDay)}'),
                              ).animate().fadeIn(
                                    duration: const Duration(milliseconds: 500),
                                  );
                            }
                            final tasksList = snapshot.data!.docs;
                            return ListView.builder(
                                itemCount: tasksList.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final doc = tasksList[index];
                                  final eventId = doc['eventId'];
                                  final eventTitle = doc['eventName'];
                                  final eventDetails = doc['eventNotes'];
                                  final Timestamp endDateTime =
                                      doc['eventEndDateTime'];
                                  final DateTime eventEndDateTime =
                                      endDateTime.toDate();
                                  final Timestamp startDateTime =
                                      doc['eventStartDateTime'];
                                  final DateTime eventStartDateTime =
                                      startDateTime.toDate();
                                  final String color =
                                      doc['eventColorCode'] ?? '';
                                  final Color eventColorCode = Color(
                                      int.parse(color, radix: 16) + 0xFF000000);
                                  final int? eventUniqueId =
                                      doc['eventUniqueId'];
                                  final bool isAttended =
                                      doc['isAttended'] ?? false;
                                  return Column(
                                    children: [
                                      EventsTile(
                                        innerPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 4),
                                        eventId: eventId,
                                        eventStartDateTime: eventStartDateTime,
                                        eventName: eventTitle,
                                        eventNotes: eventDetails ?? '',
                                        eventEndDateTime: eventEndDateTime,
                                        eventColorCode: eventColorCode,
                                        eventUniqueId: eventUniqueId ?? 0,
                                        isAttended: isAttended,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14.0),
                                        child: const Divider().animate().fade(
                                            delay: const Duration(
                                                milliseconds: 250)),
                                      )
                                    ],
                                  );
                                });
                          },
                        ),
                      ],
                    ),
                  ),
      ),
      bottomSheet:
          // Display and AD in between the events tile and tasks tile (testing)
          isAdLoaded && Platform.isAndroid
              ? SizedBox(
                  height: bannerAd.size.height.toDouble(),
                  width: bannerAd.size.width.toDouble(),
                  child: Center(child: AdWidget(ad: bannerAd)),
                )
              : const SizedBox(),
      // Add task floating button
      floatingActionButton: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: () {
          // Check if the platform is windows or android
          // And display a sheet if android and dialog if windows
          Platform.isWindows
              ? showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            AddEventModalSheet(currentDateTime: _focusedDay),
                          ],
                        ),
                      ),
                    );
                  },
                )
              :
              // Add new event process
              showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  builder: (BuildContext context) {
                    return AddEventModalSheet(
                      currentDateTime: _focusedDay,
                    );
                  },
                  showDragHandle: true,
                );
        },
        child: Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(100)),
          child: Icon(
            Icons.add,
            size: 25,
            color: Theme.of(context).textTheme.labelMedium?.color,
          ),
        ).animate().scaleXY(
              curve: Curves.easeInOutBack,
              duration: const Duration(
                milliseconds: 800,
              ),
            ),
      ),
    ).animate().fadeIn(
          duration: const Duration(milliseconds: 500),
        );
  }
}

class Event {
  final String id;
  final String title;
  final String description;

  Event({required this.id, required this.title, required this.description});
}
