import 'dart:async';

import 'package:bloom/components/overview_data.dart';
import 'package:bloom/models/dashboard_card_layout.dart';
import 'package:bloom/screens/calendar_screen.dart';
import 'package:bloom/screens/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class DashboardScreen extends StatefulWidget {
  final bool isAndroid;
  const DashboardScreen({super.key, required this.isAndroid});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final user = FirebaseAuth.instance.currentUser;
  var today = DateTime.now();
  var _focusedDay = DateTime.now();
  var _selectedDay = DateTime.now();
  CalendarFormat calendarFormat = CalendarFormat.week;
  int? pendingTasks;
  int? numberOfSchedules;
  int? numberOfEntries;
  int? numberOfEntriesInYear;
  int? completedTasksInYear;
  int? attendedEventsInYear;
  String? profilePicture;
  String? email;
  String? userName = '';
  String? font;
  bool? isImageNetwork;
  bool? isFirstTime;
  double dailyProgressValue = 0.0;
  late BannerAd bannerAd;
  bool isAdLoaded = false;
  List<DateTime> dates = [];
  int numberOfHabits = 0;
  bool isTaskEmpty = false;
  bool isEventEmpty = false;
  final ScrollController scrollController = ScrollController();
  Timer? _timer;
  bool displayNoInternet = false;

  @override
  void initState() {
    super.initState();
    dataOverviewCheck(_focusedDay);
    // initBannerAd();
    fetchAccountData();
    // Check every 5 seconds
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      bool connected = await hasInternet();
      if (!connected) {
        displayNoInternet = true;
      } else {
        displayNoInternet = false;
      }
    });
  }

  // Fetch accountData
  void fetchAccountData() async {
    // Replace 'users' with your actual collection name
    final docRef =
        FirebaseFirestore.instance.collection('users').doc(user?.uid);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      setState(() {
        profilePicture = data?['profilePicture'];
        email = data?['email'];
        userName = data?['userName'];
        isImageNetwork = data?['isImageNetwork'];
        isFirstTime = data?['isFirstTime'] ?? true;
      });
    } else {}
  }

  void dataOverviewCheck(DateTime date) async {
    var dayStart = DateTime(date.year, date.month, date.day, 0, 0, 0);
    var dayEnd = DateTime(date.year, date.month, date.day, 23, 59, 59);
    var dateString = DateFormat('yyyy-MM-dd').format(date);
    List<DateTime> taskDateTimes = [];
    int habitLength = 0;
    List<DateTime> eventDateTimes = [];

    try {
      final baseRef =
          FirebaseFirestore.instance.collection('users').doc(user?.uid);

      final taskQuery = baseRef
          .collection('tasks')
          .where('isCompleted', isEqualTo: false)
          .where('taskDateTime', isGreaterThanOrEqualTo: dayStart)
          .where('taskDateTime', isLessThanOrEqualTo: dayEnd)
          .get();

      // Query the completed tasks for the day to calculate progress
      final completedTaskTodayQuery = baseRef
          .collection('tasks')
          .where('isCompleted', isEqualTo: true)
          .where('taskDateTime', isGreaterThanOrEqualTo: dayStart)
          .where('taskDateTime', isLessThanOrEqualTo: dayEnd)
          .count()
          .get();

      final habitQuery = baseRef
          .collection('habits')
          .where('habitDateTime', isGreaterThanOrEqualTo: dayStart)
          .where('habitDateTime', isLessThanOrEqualTo: dayEnd)
          .get();

      final eventQuery = baseRef
          .collection('events')
          .where('isAttended', isEqualTo: false)
          .where('eventStartDateTime', isGreaterThanOrEqualTo: dayStart)
          .where('eventEndDateTime', isLessThanOrEqualTo: dayEnd)
          .get();

      // Query the attended events for the day to calculate progress
      final attendedEventTodayQuery = baseRef
          .collection('events')
          .where('isAttended', isEqualTo: true)
          .where('eventStartDateTime', isGreaterThanOrEqualTo: dayStart)
          .where('eventEndDateTime', isLessThanOrEqualTo: dayEnd)
          .count()
          .get();

      final entryQuery = baseRef
          .collection('entries')
          .where('dateTime', isGreaterThanOrEqualTo: dayStart)
          .where('dateTime', isLessThanOrEqualTo: dayEnd)
          .count() // Using count for efficiency
          .get();

      // Get the current year
      DateTime now = DateTime.now();
      DateTime startOfYear = DateTime(now.year, 1, 1); // Start of the year
      DateTime endOfYear = DateTime(now.year + 1, 1, 1)
          .subtract(const Duration(seconds: 1)); // End of the year

      // Query the entries within the current year
      final entriesInYearQuery = baseRef
          .collection('entries')
          .where('dateTime', isGreaterThanOrEqualTo: startOfYear)
          .where('dateTime', isLessThanOrEqualTo: endOfYear)
          .count()
          .get();

      // Query the completed tasks within current year
      final tasksInYearQuery = baseRef
          .collection('tasks')
          .where('taskDateTime', isGreaterThanOrEqualTo: startOfYear)
          .where('taskDateTime', isLessThanOrEqualTo: endOfYear)
          .where('isCompleted', isEqualTo: true)
          .count()
          .get();

      // Query the events attended within current year
      final eventsInYearQuery = baseRef
          .collection('events')
          .where('eventStartDateTime', isGreaterThanOrEqualTo: startOfYear)
          .where('eventEndDateTime', isLessThanOrEqualTo: endOfYear)
          .where('isAttended', isEqualTo: true)
          .count()
          .get();

      // Wait for all the queries to complete
      final results = await Future.wait([
        taskQuery,
        habitQuery,
        eventQuery,
        entryQuery,
        entriesInYearQuery,
        tasksInYearQuery,
        eventsInYearQuery,
        completedTaskTodayQuery,
        attendedEventTodayQuery,
      ]);

      final taskSnapshot = results[0] as QuerySnapshot;
      final habitSnapshot = results[1] as QuerySnapshot;
      final eventSnapshot = results[2] as QuerySnapshot;
      final entryCount = (results[3] as AggregateQuerySnapshot).count;
      final yearEntriesCount = (results[4] as AggregateQuerySnapshot).count;
      final yearTasksCount = (results[5] as AggregateQuerySnapshot).count;
      final yearEventsCount = (results[6] as AggregateQuerySnapshot).count;
      final todayCompletedTasksCount =
          (results[7] as AggregateQuerySnapshot).count;
      final todayAttendedEventsCount =
          (results[8] as AggregateQuerySnapshot).count;

      // Habit completion logic for progress calculation
      int completedHabitsToday = 0;
      for (var doc in habitSnapshot.docs) {
        List completedDates = doc['completedDates'] ?? [];
        if (completedDates.contains(dateString)) {
          completedHabitsToday++;
        }
      }

      // Extract task and event dates
      taskDateTimes = taskSnapshot.docs
          .map((doc) => (doc['taskDateTime'] as Timestamp).toDate())
          .toList();

      habitLength = habitSnapshot.docs.length;

      eventDateTimes = eventSnapshot.docs
          .map((doc) => (doc['eventEndDateTime'] as Timestamp).toDate())
          .toList();

      // Update state
      setState(() {
        pendingTasks = taskSnapshot.size;
        numberOfHabits = habitLength;
        numberOfSchedules = eventSnapshot.size;
        numberOfEntries = entryCount;
        numberOfEntriesInYear = yearEntriesCount;
        completedTasksInYear = yearTasksCount;
        attendedEventsInYear = yearEventsCount;

        isTaskEmpty = taskSnapshot.size == 0;
        isEventEmpty = eventSnapshot.size == 0;

        dates = [...taskDateTimes, ...eventDateTimes]; // Combine both lists
        dates.sort();

        // Total items planned for today across all categories
        int totalPlanned = pendingTasks! +
            todayCompletedTasksCount! +
            numberOfSchedules! +
            todayAttendedEventsCount! +
            habitLength;

        // Progress value calculation including habits
        dailyProgressValue = totalPlanned > 0
            ? (todayCompletedTasksCount +
                    todayAttendedEventsCount +
                    completedHabitsToday) /
                totalPlanned
            : 0.0;
      });
    } catch (e) {
      //
    }
  }

  Future<bool> hasInternet() async {
    try {
      if (kIsWeb) {
        return true;
      } else {
        // We use a HEAD request because it's lightweight (no body downloaded)
        final response = await http.head(Uri.parse('https://google.com'));
        return response.statusCode == 200;
      }
    } catch (_) {
      return false;
    }
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

// Banner ADs initialization method
  void initBannerAd() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: "ca-app-pub-5607290715305671/4873045589",
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
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    String progressPercentage = (dailyProgressValue * 100).toStringAsFixed(0);
    return Scaffold(
      extendBody: true,
      // List the tasks and events
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          // SliverAppBar with all the overview content
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: false,
            expandedHeight: 170,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                children: [
                  // Greetings and Username
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            spacing: 5,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateTime.now().hour < 12
                                    ? "Good morning"
                                    : DateTime.now().hour > 12 &&
                                            DateTime.now().hour < 4
                                        ? "Good afternoon"
                                        : "Good evening",
                                textAlign: TextAlign.left,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontSize: 26,
                                      fontFamily: 'ClashGrotesk',
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(4),
                                onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => ProfileScreen(
                                            isImageNetwork: isImageNetwork,
                                            profilePicture: profilePicture,
                                            userName: userName == '' ||
                                                    userName == null
                                                ? user!.email!.substring(0, 8)
                                                : userName,
                                            uid: user!.uid,
                                            email: email,
                                            mode: ProfileMode.display))),
                                child: userName == null || userName == ''
                                    ? Hero(
                                        tag: 'userName_hero',
                                        transitionOnUserGestures: true,
                                        placeholderBuilder:
                                            (context, heroSize, child) {
                                          return Text(
                                            user!.email!.substring(0, 8),
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall
                                                ?.copyWith(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                          );
                                        },
                                        child: Text(
                                          user!.email!.substring(0, 8),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.copyWith(
                                                overflow: TextOverflow.ellipsis,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                              ),
                                        ),
                                      )
                                    : Hero(
                                        tag: 'userName_hero',
                                        child: Text(
                                          '$userName',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.copyWith(
                                                overflow: TextOverflow.ellipsis,
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                              ),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Day completion percentage of the user
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                  progressPercentage == '100'
                                      ? '✅'
                                      : '$progressPercentage%',
                                  style: TextStyle(fontSize: 12)),
                              CircularProgressIndicator(
                                year2023: false,
                                value: dailyProgressValue,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  // Overview data of the day for the user
                  Container(
                    width: double.maxFinite,
                    margin: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).colorScheme.surfaceContainer),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(child: TaskData(numberOfTasks: pendingTasks)),
                        Expanded(
                            child: HabitData(numberOfHabits: numberOfHabits)),
                        Expanded(
                            child: SchedulesData(
                                numberOfSchedules: numberOfSchedules)),
                        Expanded(
                          child: EntriesData(
                              numberOfEntries: numberOfEntries ?? 0),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Persistent HeaderBar (AppBar)
          // Inside SliverPersistentHeader
          SliverPersistentHeader(
            pinned: true,
            floating: false,
            delegate: _CalendarHeaderDelegate(
              minExtent: 90,
              maxExtent: 100,
              childBuilder: (context, shrinkOffset) {
                final scrollPercent =
                    (shrinkOffset / (100 - 90)).clamp(0.0, 1.0);
                final color = Color.lerp(
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surfaceContainerHigh,
                  scrollPercent,
                )!;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  color: color,
                  padding:
                      const EdgeInsets.only(left: 14.0, right: 14.0, top: 14),
                  child: TableCalendar(
                    focusedDay: _focusedDay,
                    headerVisible: false,
                    firstDay: DateTime.utc(2010, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    availableCalendarFormats: const {
                      CalendarFormat.week: 'Week',
                    },
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    calendarFormat: calendarFormat,
                    onFormatChanged: (format) {
                      setState(() {
                        calendarFormat = format;
                      });
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      onDaySelected(selectedDay, focusedDay);
                      dataOverviewCheck(selectedDay);
                    },
                    onDayLongPressed: (selectedDay, focusedDay) {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            CalendarViewScreen(initialDay: selectedDay),
                      ));
                    },
                    calendarStyle: CalendarStyle(
                      isTodayHighlighted: false,
                      selectedDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // SliverAppBar Content
          SliverList(
              delegate: SliverChildListDelegate([
            displayNoInternet == true
                ? Padding(
                    padding: EdgeInsets.only(left: 14.0, right: 14.0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image(
                            height: 250,
                            width: 250,
                            image:
                                AssetImage('assets/images/deviceOffline.png'),
                          ),
                          Text(
                            'Nothing to see here',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 24),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            'Lost connection to the internet',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 4,
                          ),
                        ],
                      ),
                    ),
                  )
                : isEventEmpty == true &&
                        isTaskEmpty == true &&
                        numberOfEntries == 0 &&
                        numberOfHabits == 0
                    ? Padding(
                        padding: EdgeInsets.only(left: 14.0, right: 14.0),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              displayNoInternet == true
                                  ? Image(
                                      height: 250,
                                      width: 250,
                                      image: AssetImage(
                                          'assets/images/deviceOffline.png'),
                                    )
                                  : Image(
                                      height: 250,
                                      width: 250,
                                      image: AssetImage(
                                          'assets/images/allCompletedBackground.png'),
                                    ),
                              Text(
                                'Nothing to see here',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 24),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              displayNoInternet == true
                                  ? Text(
                                      'Lost connection to the internet',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey),
                                      textAlign: TextAlign.center,
                                    )
                                  : Text(
                                      isFirstTime == true
                                          ? 'Add new tasks, events or notes to get started'
                                          : 'Click on the + icon to add a new object',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey),
                                      textAlign: TextAlign.center,
                                    ),
                              SizedBox(
                                height: 4,
                              ),
                            ],
                          ),
                        ),
                      ).animate().fade(delay: Duration(milliseconds: 600))
                    : SafeArea(
                        child: Container(
                          height: MediaQuery.of(context).size.height,
                          padding: const EdgeInsets.only(
                              left: 14.0, right: 14, bottom: 14),
                          child: DashboardCardLayout(
                              // numberOfTasks: pendingTasks ?? 0,
                              // numberOfSchedules: numberOfSchedules ?? 0,
                              // numberOfEntries: numberOfEntries ?? 0,
                              // numberOfHabits: numberOfHabits ?? 0,
                              focusedDay: _selectedDay),
                        ),
                      ),
          ]))
        ],
      ),
      bottomSheet:
          // Display and AD in between the events tile and tasks tile (testing)
          isAdLoaded && defaultTargetPlatform == TargetPlatform.android
              ? SizedBox(
                  height: bannerAd.size.height.toDouble(),
                  width: bannerAd.size.width.toDouble(),
                  child: Center(child: AdWidget(ad: bannerAd)),
                )
              : const SizedBox(),
    );
  }
}

/// [TableCalendar] widget for [SliverPersistentHeader] as a Persistent [AppBar].
class _CalendarHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  final double minExtent;
  @override
  final double maxExtent;
  final Widget Function(BuildContext, double) childBuilder;

  _CalendarHeaderDelegate({
    required this.minExtent,
    required this.maxExtent,
    required this.childBuilder,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return childBuilder(context, shrinkOffset);
  }

  @override
  bool shouldRebuild(_CalendarHeaderDelegate oldDelegate) {
    return oldDelegate.minExtent != minExtent ||
        oldDelegate.maxExtent != maxExtent ||
        oldDelegate.childBuilder != childBuilder;
  }
}
