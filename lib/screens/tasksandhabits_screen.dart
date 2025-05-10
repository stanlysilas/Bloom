import 'dart:io';

import 'package:bloom/components/add_taskorhabit.dart';
import 'package:bloom/components/mybuttons.dart';
import 'package:bloom/components/mytextfield.dart';
import 'package:bloom/components/tasktile.dart';
import 'package:bloom/screens/habitstabview.dart';
import 'package:bloom/screens/taskstabview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iconsax/iconsax.dart';
import 'package:table_calendar/table_calendar.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with TickerProviderStateMixin {
  final user = FirebaseAuth.instance.currentUser;
  late TextEditingController searchController;
  String completedSortValue = 'Incomplete';
  bool toggleDayView = false;
  bool toggleSearch = false;
  List<DocumentSnapshot> searchResults = [];
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

  @override
  void initState() {
    searchController = TextEditingController();
    searchController.addListener(onSearchChanged);
    fetchTasksForCalendar();
    // initBannerAd();
    tasksCompletedDates();
    super.initState();
    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    setState(() {
      tabIndex = _tabController.index;
    });
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
        .collection('tasks')
        .where('taskName', isGreaterThanOrEqualTo: query)
        .where('taskName', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    setState(() {
      searchResults = snapshot.docs;
    });
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
          tabIndex == 0 ? 'Tasks' : 'Habits',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          // Display a streak dialog box for tasks (temporary)
          InkWell(
              borderRadius: BorderRadius.circular(100),
              onTap: () => showStreakDialogBox(context, 'tasksCompletedDates',
                  'Tasks', isTodayCompleted!, clearStreaks),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isTodayCompleted == true
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).primaryColorLight,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
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
              icon: const Icon(Icons.search)),
          IconButton(
              tooltip: 'Toggle view',
              onPressed: () {
                fetchTasksForCalendar();
                setState(() {
                  toggleDayView = !toggleDayView;
                });
              },
              icon: toggleDayView
                  ? const Icon(Iconsax.task_square4)
                  : const Icon(Iconsax.calendar_1))
        ],
        bottom: TabBar(
            controller: _tabController,
            onTap: (value) {
              setState(() {
                tabIndex = value;
              });
            },
            dividerColor: Colors.transparent,
            indicatorColor: Theme.of(context).primaryColor,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(
                icon: Text('Tasks'),
              ),
              Tab(
                icon: Text('Habits'),
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
                    const SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: MyTextfield(
                        controller: searchController,
                        hintText: 'Search title of task (Case Sensitive)',
                        obscureText: false,
                        textInputType: TextInputType.text,
                        autoFocus: false,
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
                                    'Enter the name of a task to search for it. Searches are case sensitive.',
                                    style: TextStyle(color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    "Eg: If a task name is 'Task name', then it won't be shown if you search 'task name'",
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
                              ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot doc = searchResults[index];
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
                            bool isHabit = doc['isHabit'] ?? false;
                            String taskMode = doc['taskMode'];
                            if (searchResults.isEmpty) {
                              return const Center(
                                child: Text(
                                  'There is no matching data',
                                ),
                              );
                            } else {
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
                  titleTextStyle:
                      const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                  formatButtonTextStyle:
                      const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
                    color: Theme.of(context).primaryColor,
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
            const SizedBox(height: 8,),
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: TabBarView(controller: _tabController, children: [
                // Tasks tab view
                Taskstabview(
                  focusedDay: _focusedDay,
                  toggleDayView: toggleDayView,
                  toggleSearch: toggleSearch,
                ),
                // Habits tab
                Habitstabview(
                    toggleSearch: toggleSearch,
                    toggleDayView: toggleDayView,
                    focusedDay: _focusedDay),
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
                        height: MediaQuery.of(context).size.height * 0.85,
                        child: AddTaskOrHabitModal(currentDateTime: DateTime.now()),
                      ),
                    );
                  },
                )
              :
              // Add new task process
              showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width,
                    maxHeight: MediaQuery.of(context).size.height,
                  ),
                  builder: (BuildContext context) {
                    return Scaffold(
                      body: AddTaskOrHabitModal(
                        currentDateTime: DateTime.now(),
                        isHabit: tabIndex == 0 ? false : true,
                      ),
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
            color: Theme.of(context).textTheme.bodyMedium?.color,
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
