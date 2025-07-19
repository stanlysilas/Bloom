import 'dart:io';

import 'package:bloom/components/add_taskorhabit.dart';
import 'package:bloom/components/events_tile.dart';
import 'package:bloom/components/habit_tile.dart';
import 'package:bloom/components/mybuttons.dart';
import 'package:bloom/components/tasktile.dart';
import 'package:bloom/screens/eventstabview.dart';
import 'package:bloom/screens/habitstabview.dart';
import 'package:bloom/screens/taskstabview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:table_calendar/table_calendar.dart';

class GoalsScreen extends StatefulWidget {
  final int? tabIndex;
  const GoalsScreen({super.key, this.tabIndex});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen>
    with TickerProviderStateMixin {
  final user = FirebaseAuth.instance.currentUser;
  late TextEditingController searchController;
  final searchFocusNode = FocusNode();
  String completedSortValue = 'Incomplete';
  bool toggleDayView = false;
  bool toggleSearch = false;
  List<Map<String, dynamic>> searchResults = [];
  late BannerAd bannerAd;
  bool isAdLoaded = false;
  int? tasksStreak;
  List<DateTime> tasksStreaksDates = [];
  bool? isTodayCompleted;
  bool? clearStreaks;
  late final TabController _tabController;
  late int tabIndex;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  var _focusedDay = DateTime.now();
  var _selectedDay = DateTime.now();
  String searchObject = 'tasks';

  @override
  void initState() {
    searchController = TextEditingController();
    searchController.addListener(onSearchChanged);
    fetchTasksForCalendar();
    // initBannerAd();
    tasksCompletedDates();
    super.initState();
    _tabController = TabController(
        initialIndex: widget.tabIndex ?? 0, length: 3, vsync: this);
    setState(() {
      tabIndex = _tabController.index;
    });
  }

  // To update the state
  void stateUpdate() {
    setState(() {});
  }

// Banner ADs initialization method
  initBannerAd() {
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: "ca-app-pub-5607290715305671/2732600428",
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

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  void tasksCompletedDates() async {
    final now = DateTime.now();
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('streaks')
        .doc('streaks')
        .get()
        .then((value) async {
      setState(() {
        if (value.exists && value.data()!.containsKey('tasksCompletedDates')) {
          final List<Timestamp> list =
              List<Timestamp>.from(value['tasksCompletedDates'] ?? []);

          // Convert timestamps to DateTime objects
          tasksStreaksDates =
              list.map((timestamp) => timestamp.toDate()).toList();
          tasksStreaksDates.sort();

          tasksStreak = tasksStreaksDates.length;

          // Check if today's date is in the list
          DateTime today = DateTime(now.year, now.month, now.day);
          isTodayCompleted = tasksStreaksDates.any((date) =>
              date.year == today.year &&
              date.month == today.month &&
              date.day == today.day);

          // Check if yesterday or today is completed
          if (tasksStreaksDates.any((date) =>
                  date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day - 1) ||
              isTodayCompleted!) {
            clearStreaks = false;
            isTodayCompleted = false;
          } else {
            clearStreaks = true;

            // Reset streak in Firestore
            FirebaseFirestore.instance
                .collection('users')
                .doc(user?.uid)
                .collection('streaks')
                .doc('streaks')
                .set({
              'tasksCompletedDates': [],
            });
          }
        } else {
          tasksStreak = 0;
          isTodayCompleted = false;
          clearStreaks = false;
        }
      });
    });
  }

  void onSearchChanged() {
    searchFirestore(searchController.text);
  }

  Future<List<Map<String, dynamic>>> searchFirestore(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return [];
    }

    QuerySnapshot<Map<String, dynamic>> querySnapshot;
    List<Map<String, dynamic>> tempResults = [];

    try {
      if (searchObject == 'tasks') {
        querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('tasks')
            .where('taskName', isGreaterThanOrEqualTo: query)
            .where('taskName', isLessThanOrEqualTo: '$query\uf8ff')
            .get();
        tempResults = querySnapshot.docs.map((doc) => doc.data()).toList();
      } else if (searchObject == 'habits') {
        querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('habits')
            .where('habitName', isGreaterThanOrEqualTo: query)
            .where('habitName', isLessThanOrEqualTo: '$query\uf8ff')
            .get();
        tempResults = querySnapshot.docs.map((doc) => doc.data()).toList();
      } else if (searchObject == 'events') {
        querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('events')
            .where('eventName', isGreaterThanOrEqualTo: query)
            .where('eventName', isLessThanOrEqualTo: '$query\uf8ff')
            .get();
        tempResults = querySnapshot.docs.map((doc) => doc.data()).toList();
      } else {
        // Handle the case where searchObject is not one of the expected values
        setState(() {
          searchResults = [];
        });
        return [];
      }

      setState(() {
        searchResults = tempResults;
      });

      return tempResults; // Return the results from the function
    } catch (e) {
      setState(() {
        searchResults = []; // Clear results on error
      });
      return []; // Return empty list on error
    }
  }

  Map<DateTime, List<Task>> _tasks = {};

  // fetch tasks for displaying dot on the calendar
  Future<void> fetchTasksForCalendar() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('tasks')
        .where('isCompleted', isEqualTo: false)
        .get();

    Map<DateTime, List<Task>> tasks = {};

    for (var doc in snapshot.docs) {
      Timestamp timestamp = doc['taskDateTime'];
      DateTime dateTime = timestamp.toDate();
      DateTime date = normalizeDate(dateTime);
      Task task = Task(
        id: doc.id,
        title: doc['taskName'],
        description: doc['taskNotes'],
      );

      // Group events by date
      if (tasks[date] == null) {
        tasks[date] = [];
      }
      tasks[date]!.add(task);
    }

    setState(() {
      _tasks = tasks;
    });
  }

  DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day, 0, 0, 0);
  }

  @override
  void dispose() {
    super.dispose();
    searchController.removeListener(onSearchChanged);
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          toggleSearch
              ? 'Search'
              : tabIndex == 0
                  ? 'Tasks'
                  : tabIndex == 1
                      ? 'Habits'
                      : tabIndex == 2
                          ? 'Events'
                          : 'Goals',
        ),
        actions: [
          // Display a streak dialog box for tasks (temporary)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                decoration: BoxDecoration(
                  color: isTodayCompleted == true
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).primaryColorLight,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: IconButton(
                  onPressed: () => showStreakDialogBox(
                      context,
                      'tasksCompletedDates',
                      'Tasks',
                      isTodayCompleted!,
                      clearStreaks),
                  icon: Row(
                    children: [
                      isTodayCompleted == true
                          ? const Text('🔥')
                          : clearStreaks == false
                              ? const Text('⚠️')
                              : const Text('❄️'),
                      const SizedBox(
                        width: 4,
                      ),
                      tasksStreak.toString().isEmpty || tasksStreak == null
                          ? Text(
                              '0',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color),
                            )
                          : Text(
                              tasksStreak.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color),
                            )
                    ],
                  ),
                )),
          ),
          IconButton(
              tooltip: 'Search',
              onPressed: () {
                setState(() {
                  // Set search to true
                  toggleSearch = !toggleSearch;
                });
                toggleSearch == false
                    ? searchController.clear()
                    : searchController.text;
              },
              icon: const Icon(Icons.search_rounded)),
          // if (_tabController.index == 0)
          //   IconButton(
          //     tooltip: 'Filter',
          //     onPressed: () {},
          //     icon: Icon(Icons.filter_list_rounded),
          //   ),
          // IconButton(
          //     tooltip: 'Toggle view',
          //     onPressed: () {
          //       fetchTasksForCalendar();
          //       setState(() {
          //         toggleDayView = !toggleDayView;
          //       });
          //     },
          //     icon: toggleDayView
          //         ? const Icon(Iconsax.task_square4)
          //         : const Icon(Iconsax.calendar_1))
        ],
        bottom: toggleSearch
            ? PreferredSize(
                preferredSize: Size(MediaQuery.of(context).size.width, 70),
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                  child: SearchBar(
                    controller: searchController,
                    focusNode: searchFocusNode,
                    backgroundColor: WidgetStatePropertyAll(
                        Theme.of(context).primaryColorLight),
                    padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 16.0)),
                    onTapOutside: (event) {
                      searchFocusNode.unfocus();
                    },
                    leading: const Icon(Icons.search_rounded),
                    trailing: [
                      if (searchController.text.isNotEmpty)
                        IconButton(
                            onPressed: () {
                              searchController.clear();
                              searchFocusNode.unfocus();
                            },
                            icon: const Icon(Icons.close_rounded))
                    ],
                    hintText: 'Search $searchObject (case sensitive)',
                    elevation: const WidgetStatePropertyAll(0),
                  ),
                ))
            : TabBar(
                controller: _tabController,
                onTap: (value) {
                  setState(() {
                    tabIndex = value;
                  });
                },
                dividerColor: Colors.transparent,
                indicatorColor: Theme.of(context).primaryColor,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.white,
                tabs: const [
                    Tab(
                      // icon: Icon(Icons.task_alt_rounded),
                      text: 'Tasks',
                    ),
                    Tab(
                      // icon: Icon(Icons.repeat_rounded),
                      text: 'Habits',
                    ),
                    Tab(
                      // icon: Icon(Icons.event_rounded),
                      text: 'Events',
                    )
                  ]),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (toggleSearch)
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // RawChip to select the object to search for
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: Row(
                        spacing: 8,
                        children: [
                          // Tasks search button
                          RawChip(
                            backgroundColor: searchObject == 'tasks'
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).primaryColorLight,
                            side: BorderSide.none,
                            avatar: searchObject == 'tasks'
                                ? Icon(Icons.check_rounded)
                                : Icon(Icons.filter_list_off_rounded),
                            iconTheme: IconThemeData(
                                color: searchObject == 'tasks'
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                    : Theme.of(context).primaryColor),
                            label: Text('Tasks'),
                            labelStyle: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color),
                            onPressed: () {
                              setState(() {
                                searchObject = 'tasks';
                                searchController.clear();
                                searchFocusNode.unfocus();
                                searchResults.clear();
                              });
                            },
                          ),
                          // Habits search enable button
                          RawChip(
                            backgroundColor: searchObject == 'habits'
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).primaryColorLight,
                            side: BorderSide.none,
                            avatar: searchObject == 'habits'
                                ? Icon(Icons.check_rounded)
                                : Icon(Icons.filter_list_off_rounded),
                            iconTheme: IconThemeData(
                                color: searchObject == 'habits'
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                    : Theme.of(context).primaryColor),
                            label: Text('Habits'),
                            labelStyle: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color),
                            onPressed: () {
                              setState(() {
                                searchObject = 'habits';
                                searchController.clear();
                                searchFocusNode.unfocus();
                                searchResults.clear();
                              });
                            },
                          ),
                          // Events search enable button
                          RawChip(
                            backgroundColor: searchObject == 'events'
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).primaryColorLight,
                            side: BorderSide.none,
                            avatar: searchObject == 'events'
                                ? Icon(Icons.check_rounded)
                                : Icon(Icons.filter_list_off_rounded),
                            iconTheme: IconThemeData(
                                color: searchObject == 'events'
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                    : Theme.of(context).primaryColor),
                            label: Text('Events'),
                            labelStyle: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color),
                            onPressed: () {
                              setState(() {
                                searchObject = 'events';
                                searchController.clear();
                                searchFocusNode.unfocus();
                                searchResults.clear();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    searchResults.isEmpty && searchController.text.isEmpty
                        ? Expanded(
                            child: Center(
                                child: Padding(
                              padding: EdgeInsets.only(left: 14.0, right: 14.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Enter the name of a $searchObject to search for it. Searches are case sensitive.',
                                    style: TextStyle(color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    "Eg: If a $searchObject name is '$searchObject name', then it won't be shown if you search '$searchObject name'",
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500),
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
                              ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            final doc = searchResults[index];
                            if (searchObject == 'tasks') {
                              String taskName = doc['taskName'];
                              String taskNotes = doc['taskNotes'];
                              String taskId = doc['taskId'];
                              int taskUniqueId = doc['taskUniqueId'] ?? 0;
                              List taskGroups = doc['taskGroups'];
                              String taskGroupNames = taskGroups.join(',');
                              Timestamp timestamp = doc['taskDateTime'];
                              DateTime taskDateTime = timestamp.toDate();
                              bool isCompleted = doc['isCompleted'];
                              Timestamp timeStamp = doc['addedOn'];
                              DateTime addedOn = timeStamp.toDate();
                              int priorityLevel = doc['priorityLevel'];
                              String priorityLevelString =
                                  doc['priorityLevelString'];
                              String taskMode = doc['taskMode'];
                              if (searchResults.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'There is no matching data',
                                  ),
                                );
                              } else {
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
                              }
                            } else if (searchObject == 'habits') {
                              final doc = searchResults[index];
                              String habitId = doc['habitId'];
                              String habitName = doc['habitName'];
                              String habitNotes = doc['habitNotes'];
                              int habitUniqueId = doc['habitUniqueId'] ?? 0;
                              Timestamp timestamp = doc['habitDateTime'];
                              List daysOfWeek = doc['daysOfWeek'] ?? [];
                              List completedDaysOfWeek =
                                  doc['completedDaysOfWeek'] ?? [];
                              List completedDates = doc['completedDates'] ?? [];
                              DateTime habitDateTime = timestamp.toDate();
                              List habitGroups = doc['habitGroups'];
                              Timestamp timeStamp = doc['addedOn'];
                              DateTime addedOn = timeStamp.toDate();
                              return HabitTile(
                                innerPadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
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
                              );
                            } else if (searchObject == 'events') {
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
                              final String color = doc['eventColorCode'] ?? '';
                              final Color eventColorCode = Color(
                                  int.parse(color, radix: 16) + 0xFF000000);
                              final int? eventUniqueId = doc['eventUniqueId'];
                              final bool isAttended =
                                  doc['isAttended'] ?? false;
                              return EventsTile(
                                innerPadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                eventId: eventId,
                                eventStartDateTime: eventStartDateTime,
                                eventName: eventTitle,
                                eventNotes: eventDetails ?? '',
                                eventEndDateTime: eventEndDateTime,
                                eventColorCode: eventColorCode,
                                eventUniqueId: eventUniqueId ?? 0,
                                isAttended: isAttended,
                              );
                            } else {
                              return Center(
                                child: Text('No results for this search query'),
                              );
                            }
                          }),
                    ),
                  ],
                ),
              ),
            // Calendar at the top for tasks/habits
            if (toggleDayView)
              // Display the calendar at top
              TableCalendar(
                pageAnimationCurve: Curves.easeInBack,
                pageAnimationDuration: const Duration(milliseconds: 500),
                formatAnimationCurve: Curves.easeInOut,
                formatAnimationDuration: const Duration(milliseconds: 500),
                focusedDay: _focusedDay,
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                headerStyle: HeaderStyle(
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
                daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(fontWeight: FontWeight.w500)),
                calendarStyle: CalendarStyle(
                  isTodayHighlighted: false,
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color),
                  weekendTextStyle: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColorDark,
                    shape: BoxShape.circle,
                  ),
                  markersAlignment: Alignment.bottomCenter,
                ),
                eventLoader: (day) {
                  // Return the list of events for the given day
                  return _tasks[normalizeDate(day)] ?? [];
                },
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Week',
                  CalendarFormat.twoWeeks: 'Month',
                  CalendarFormat.week: '2 Weeks',
                },
                calendarFormat: _calendarFormat,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onDaySelected: (selectedDay, focusedDay) {
                  onDaySelected(selectedDay, focusedDay);
                  fetchTasksForCalendar();
                },
              ),
            if (toggleDayView)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.0),
                child: Divider(),
              ),
            const SizedBox(
              height: 8,
            ),
            // TabBarView of all the goals (Tasks, Habits, Events)
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: TabBarView(controller: _tabController, children: [
                // Tasks tab view
                Taskstabview(),
                // Habits tab
                Habitstabview(),
                SchedulesScreen(),
              ]),
            ),
          ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
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
                        height: MediaQuery.of(context).size.height * 0.85,
                        child: AddTaskOrHabitModal(
                            currentDateTime: DateTime.now()),
                      ),
                    );
                  },
                )
              :
              // Add new task process
              showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  useSafeArea: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  builder: (context) => GoalObjectsModalSheet());
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          Icons.add,
          size: 24,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ).animate().scaleXY(
            curve: Curves.easeInOutBack,
            delay: const Duration(
              milliseconds: 1000,
            ),
          ),
    );
  }
}
