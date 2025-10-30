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
  int? numberOfTasks;
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
  late BannerAd bannerAd;
  bool isAdLoaded = false;
  List<DateTime> dates = [];
  int numberOfHabits = 0;
  bool isTaskEmpty = false;
  bool isEventEmpty = false;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    dataOverviewCheck(_focusedDay);
    // initBannerAd();
    fetchAccountData();
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
    List<DateTime> taskDateTimes = [];
    int habitLength = 0;
    List<DateTime> eventDateTimes = [];
    try {
      final taskQuery = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('tasks')
          .where('isCompleted', isEqualTo: false)
          .get();

      final habitQuery = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('habits')
          .get();

      final eventQuery = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('events')
          .where('isAttended', isEqualTo: false)
          .get();

      final entryQuery = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('entries')
          .where('dateTime', isGreaterThanOrEqualTo: dayStart)
          .where('dateTime', isLessThanOrEqualTo: dayEnd)
          .get();

      final isTaskEmptyQuery = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('tasks')
          .where('isCompleted', isEqualTo: false)
          .where('taskDateTime', isGreaterThanOrEqualTo: dayStart)
          .where('taskDateTime', isLessThanOrEqualTo: dayEnd)
          .get();

      final isEventEmptyQuery = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('events')
          .where('eventStartDateTime', isGreaterThanOrEqualTo: dayStart)
          .where('isAttended', isEqualTo: false)
          .get();

      // Get the current year
      DateTime now = DateTime.now();
      DateTime startOfYear = DateTime(now.year, 1, 1); // Start of the year
      DateTime endOfYear = DateTime(now.year + 1, 1, 1)
          .subtract(const Duration(seconds: 1)); // End of the year

      // Query the entries within the current year
      final entriesInYearQuery = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('entries')
          .where('dateTime', isGreaterThanOrEqualTo: startOfYear)
          .where('dateTime', isLessThanOrEqualTo: endOfYear)
          .count()
          .get()
          .then((value) {
        setState(() {
          numberOfEntriesInYear = value.count;
        });
      });

      // Query the completed tasks within current year
      final tasksInYearQuery = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('tasks')
          .where('taskDateTime', isGreaterThanOrEqualTo: startOfYear)
          .where('taskDateTime', isLessThanOrEqualTo: endOfYear)
          .where('isCompleted', isEqualTo: true)
          .count()
          .get()
          .then((value) {
        setState(() {
          completedTasksInYear = value.count;
        });
      });

      // Query the events attended within current year
      final eventsInYearQuery = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('events')
          .where('eventStartDateTime', isGreaterThanOrEqualTo: startOfYear)
          .where('eventEndDateTime', isLessThanOrEqualTo: endOfYear)
          .where('isAttended', isEqualTo: true)
          .count()
          .get()
          .then((value) {
        setState(() {
          attendedEventsInYear = value.count;
        });
      });

      // Wait for all the queries to complete
      final results = await Future.wait([
        taskQuery,
        habitQuery,
        eventQuery,
        entryQuery,
        isTaskEmptyQuery,
        isEventEmptyQuery,
        entriesInYearQuery,
        tasksInYearQuery,
        eventsInYearQuery
      ]);

      final taskSnapshot = results[0] as QuerySnapshot;
      final habitSnapshot = results[1] as QuerySnapshot;
      final eventSnapshot = results[2] as QuerySnapshot;
      final entrySnapshot = results[3] as QuerySnapshot;
      final isTaskEmptySnapshot = results[4] as QuerySnapshot;
      final isEventEmptySnapshot = results[5] as QuerySnapshot;

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
        numberOfTasks = taskSnapshot.size;
        numberOfHabits = habitLength;
        numberOfSchedules = eventSnapshot.size;
        numberOfEntries = entrySnapshot.size;
        isTaskEmpty = isTaskEmptySnapshot.size == 0 ? true : false;
        isEventEmpty = isEventEmptySnapshot.size == 0 ? true : false;
        dates = [...taskDateTimes, ...eventDateTimes]; // Combine both lists
        dates.sort();
      });
    } catch (e) {
      //
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
  }

  @override
  Widget build(BuildContext context) {
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
            expandedHeight: 160,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                children: [
                  // Collapsing AppBar
                  Expanded(
                    child: Wrap(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              children: [
                                Text(
                                  DateTime.now().hour < 12
                                      ? "Good morning"
                                      : DateTime.now().hour > 12 &&
                                              DateTime.now().hour < 4
                                          ? "Good afternoon"
                                          : "Good evening",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                ),
                                const SizedBox(
                                  width: 5,
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
                                                    fontWeight: FontWeight.w600,
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
                                                  fontWeight: FontWeight.w600,
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
                      ],
                    ),
                  ),
                  // Overview data
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 14),
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color:
                              Theme.of(context).colorScheme.surfaceContainer),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TaskData(
                            numberOfTasks: numberOfTasks,
                          ),
                          HabitData(
                            numberOfHabits: numberOfHabits,
                          ),
                          SchedulesData(
                            numberOfSchedules: numberOfSchedules,
                          ),
                          EntriesData(
                            numberOfEntries: numberOfEntriesInYear ?? 0,
                          )
                        ],
                      ),
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
                  Theme.of(context).colorScheme.surfaceContainerHighest,
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
                      dataOverviewCheck(focusedDay);
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
            isEventEmpty == true && isTaskEmpty == true && numberOfEntries == 0
                ? Padding(
                    padding: EdgeInsets.only(left: 14.0, right: 14.0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image(
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
                            Text(
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
                    ),
                  ).animate().fade(delay: Duration(milliseconds: 600))
                : SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 14.0, right: 14, bottom: 14),
                      child: DashboardCardLayout(
                          numberOfTasks: numberOfTasks ?? 0,
                          numberOfSchedules: numberOfSchedules ?? 0,
                          numberOfEntries: numberOfEntries ?? 0,
                          focusedDay: _focusedDay),
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
  final double minExtent;
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
