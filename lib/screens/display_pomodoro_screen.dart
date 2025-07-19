import 'dart:io';

import 'package:bloom/components/add_pomodoro.dart';
import 'package:bloom/components/pomodoro_tile.dart';
import 'package:bloom/screens/pomodoro_timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:table_calendar/table_calendar.dart';

class DisplayPomodoroScreen extends StatefulWidget {
  const DisplayPomodoroScreen({super.key});

  @override
  State<DisplayPomodoroScreen> createState() => _DisplayPomodoroScreenState();
}

class _DisplayPomodoroScreenState extends State<DisplayPomodoroScreen> {
  // Required vars
  final user = FirebaseAuth.instance.currentUser;
  late BannerAd bannerAd;
  bool isAdLoaded = false;
  bool toggleDayView = false;
  var _focusedDay = DateTime.now();
  var _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  // Init state method
  @override
  void initState() {
    super.initState();
    // initBannerAd();
    fetchPomodorosForCalendar();
  }

  // Banner ADs initialization method
  initBannerAd() {
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: "ca-app-pub-5607290715305671/4836853736",
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

  Map<DateTime, List<Pomodoro>> _pomodoros = {};

  // fetch tasks for displaying dot on the calendar
  Future<void> fetchPomodorosForCalendar() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('pomodoros')
        .get();

    Map<DateTime, List<Pomodoro>> pomodoros = {};

    for (var doc in snapshot.docs) {
      Timestamp timestamp = doc['pomodoroDateTime'];
      DateTime dateTime = timestamp.toDate();
      DateTime date = normalizeDate(dateTime);
      Pomodoro task = Pomodoro(
        id: doc.id,
        title: doc['pomodoroName'],
      );

      // Group events by date
      if (pomodoros[date] == null) {
        pomodoros[date] = [];
      }
      pomodoros[date]!.add(task);
    }

    setState(() {
      _pomodoros = pomodoros;
    });
  }

  // Method to retrieve pomodoro from database
  Stream<QuerySnapshot> fetchPomodoro(DateTime day) {
    var dayStart = DateTime(day.year, day.month, day.day, 0, 0, 0);
    var dayEnd = DateTime(day.year, day.month, day.day, 23, 59, 59);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('pomodoros')
        .where('pomodoroDateTime', isGreaterThanOrEqualTo: dayStart)
        .where('pomodoroDateTime', isLessThanOrEqualTo: dayEnd)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    var timerProvider =
        Provider.of<PomodoroTimerProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pomodoro',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  toggleDayView = !toggleDayView;
                });
              },
              icon: toggleDayView
                  ? const Icon(Icons.timer_rounded)
                  : const Icon(Icons.calendar_month_rounded))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Display calendar
            toggleDayView
                ? // Display the calendar at top
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
                      todayDecoration:  BoxDecoration(
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
                      markerDecoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      markersAlignment: Alignment.bottomCenter,
                    ),
                    eventLoader: (day) {
                      // Return the list of events for the given day
                      return _pomodoros[normalizeDate(day)] ?? [];
                    },
                    availableCalendarFormats: const {
                      CalendarFormat.twoWeeks: 'Week',
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
                      fetchPomodorosForCalendar();
                    },
                  )
                : const SizedBox(),
            toggleDayView
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14.0),
                    child: Divider(),
                  )
                : const SizedBox(),
            // Display pomodoros from firebase
            StreamBuilder<QuerySnapshot>(
                stream: fetchPomodoro(_focusedDay),
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
                        trailing: Text('End'),
                      ),
                    ).animate().fade(delay: const Duration(milliseconds: 50));
                  }
                  if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height / 1.5,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 14.0, right: 14.0),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Image(
                                  image: AssetImage(
                                      'assets/images/allCompletedBackground.png'),
                                ),
                              ),
                              Text(
                                "Completed all your Pomodoro's",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 18),
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
                            ],
                          ),
                        ),
                      )
                          .animate()
                          .fade(delay: const Duration(milliseconds: 100)),
                    );
                  }
                  List pomodoroList = snapshot.data!.docs;
                  return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pomodoroList.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot pomodoro = pomodoroList[index];
                        final String pomodoroName =
                            pomodoro['pomodoroName'] ?? 'Name';
                        timerProvider.workDuration = Duration(
                            minutes: pomodoro['pomodoroDuration'] ?? 25);
                        final Timestamp timestamp =
                            pomodoro['pomodoroDateTime'];
                        final DateTime pomodoroDateTime = timestamp.toDate();
                        timerProvider.shortBreakDuration = Duration(
                            minutes: pomodoro['shortBreakDuration'] ?? 5);
                        timerProvider.longBreakDuration = Duration(
                            minutes: pomodoro['longBreakDuration'] ?? 15);
                        // final Timestamp timestamp =
                        //     pomodoro['pomodoroDateTime'];
                        // final DateTime pomodoroDateTime = timestamp.toDate();
                        final pomodoroUniqueId =
                            pomodoro['pomodoroUniqueId'] ?? 0;
                        final String pomodoroId = pomodoro['pomodoroId'];
                        return PomodoroTile(
                          pomodoroName: pomodoroName,
                          pomodoroDateTime: pomodoroDateTime,
                          pomodoroDuration:
                              timerProvider.workDuration.inMinutes,
                          longBreakDuration:
                              timerProvider.longBreakDuration.inMinutes,
                          shortBreakDuration:
                              timerProvider.shortBreakDuration.inMinutes,
                          pomodoroId: pomodoroId,
                          pomodoroUniqueId: pomodoroUniqueId,
                          pomodoroTimerProvider: timerProvider,
                        );
                      });
                }),
          ],
        ),
      ),
      bottomNavigationBar:
          // Display and AD in between the events tile and tasks tile (testing)
          isAdLoaded
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
                            AddPomodoro(currentDateTime: DateTime.now()),
                          ],
                        ),
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
                    return AddPomodoro(currentDateTime: _focusedDay);
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

class Pomodoro {
  final String id;
  final String title;

  Pomodoro({
    required this.id,
    required this.title,
  });
}
