import 'dart:io';

import 'package:bloom/components/mybuttons.dart';
import 'package:bloom/components/overview_data.dart';
import 'package:bloom/models/dashboard_card_layout.dart';
// import 'package:bloom/screens/garden.dart';
import 'package:bloom/screens/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:iconsax/iconsax.dart';
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
  int? numberOfTasks;
  int? numberOfSchedules;
  int? numberOfEntriesInYear;
  int? completedTasksInYear;
  int? attendedEventsInYear;
  String? profilePicture;
  String? email;
  String? userName = '';
  String? font;
  bool? isImageNetwork;
  late BannerAd bannerAd;
  bool isAdLoaded = false;
  List<DateTime> dates = [];

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
      });
    } else {}
  }

  void dataOverviewCheck(DateTime date) async {
    var dayStart = DateTime(date.year, date.month, date.day, 0, 0, 0);
    var dayEnd = DateTime(date.year, date.month, date.day, 23, 59, 59);
    List<DateTime> taskDateTimes = [];
    List<DateTime> eventDateTimes = [];
    try {
      final taskQuery = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('tasks')
          .where('isCompleted', isEqualTo: false)
          .where('taskDateTime', isGreaterThanOrEqualTo: dayStart)
          .where('taskDateTime', isLessThanOrEqualTo: dayEnd)
          .get();

      final eventQuery = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('events')
          .where('eventStartDateTime', isGreaterThanOrEqualTo: dayStart)
          .where('isAttended', isEqualTo: false)
          .get();

      // Wait for both queries to complete
      final results = await Future.wait([taskQuery, eventQuery]);

      final taskSnapshot = results[0] as QuerySnapshot;
      final eventSnapshot = results[1] as QuerySnapshot;

      // Extract task and event dates
      taskDateTimes = taskSnapshot.docs
          .map((doc) => (doc['taskDateTime'] as Timestamp).toDate())
          .toList();

      eventDateTimes = eventSnapshot.docs
          .map((doc) => (doc['eventEndDateTime'] as Timestamp).toDate())
          .toList();

      // Update state
      setState(() {
        numberOfTasks = taskSnapshot.size;
        numberOfSchedules = eventSnapshot.size;
        dates = [...taskDateTimes, ...eventDateTimes]; // Combine both lists
        dates.sort();
      });
      // Get the current year
      DateTime now = DateTime.now();
      DateTime startOfYear = DateTime(now.year, 1, 1); // Start of the year
      DateTime endOfYear = DateTime(now.year + 1, 1, 1)
          .subtract(const Duration(seconds: 1)); // End of the year

      // Query the entries within the current year
      FirebaseFirestore.instance
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
      FirebaseFirestore.instance
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
      FirebaseFirestore.instance
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
  initBannerAd() {
    if (Platform.isAndroid) {
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

  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            // Day of the week
            Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              DateFormat('dd').format(_focusedDay),
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(
              width: 6,
            ),
            Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const Spacer(),
            // InkWell(
            //     borderRadius: BorderRadius.circular(100),
            //     onTap: () {
            //       // Navigate to the garden screen with some sort of cool animation across the screen
            //       // Navigator.of(context).push(
            //       //   PageRouteBuilder(
            //       //     transitionDuration: const Duration(milliseconds: 500),
            //       //     pageBuilder: (context, animation, secondaryAnimation) =>
            //       //         const Garden(),
            //       //     transitionsBuilder:
            //       //         (context, animation, secondaryAnimation, child) {
            //       //       return FadeTransition(
            //       //         opacity: animation,
            //       //         child: child,
            //       //       );
            //       //     },
            //       //   ),
            //       // );
            //       showAdaptiveDialog(
            //           context: context,
            //           builder: (context) {
            //             return AlertDialog.adaptive(
            //               backgroundColor:
            //                   Theme.of(context).scaffoldBackgroundColor,
            //               icon: Container(
            //                   padding: const EdgeInsets.all(20),
            //                   decoration: BoxDecoration(
            //                     color: Theme.of(context).primaryColor,
            //                     shape: BoxShape.circle,
            //                   ),
            //                   child: Icon(
            //                     Iconsax.tree,
            //                     color: Theme.of(context)
            //                         .textTheme
            //                         .bodyMedium
            //                         ?.color,
            //                   )),
            //               title: const Text('Will be available soon!'),
            //               titleTextStyle: TextStyle(
            //                 fontSize: 18,
            //                 fontWeight: FontWeight.w600,
            //                 color:
            //                     Theme.of(context).textTheme.bodyMedium?.color,
            //               ),
            //               titlePadding: const EdgeInsets.all(12),
            //               content: const Text(
            //                 'We understand your eagerness to try out our newest features. Please wait for the Garden update. Turn on notifications to recieve the news about updates.',
            //                 textAlign: TextAlign.center,
            //               ),
            //               actions: [
            //                 TextButton(
            //                     onPressed: () => Navigator.pop(context),
            //                     child: const Text(
            //                       'Close',
            //                       style: TextStyle(color: Colors.red),
            //                     ))
            //               ],
            //             );
            //           });
            //     },
            //     child: Container(
            //       padding: const EdgeInsets.all(6),
            //       alignment: Alignment.center,
            //       decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(100),
            //         color: Theme.of(context).primaryColor,
            //       ),
            //       child: const Icon(
            //         Iconsax.tree,
            //       ),
            //     )),
            const SizedBox(
              width: 6,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${DateFormat('LLL').format(_focusedDay)}'${DateFormat('yy').format(_focusedDay)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  DateFormat('EEEE').format(_focusedDay),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      // List the tasks and events
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            // Just a quick overview paragraph for the focused day
            Wrap(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        InkWell(
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => ProfileScreen(
                                      isImageNetwork: isImageNetwork,
                                      profilePicture: profilePicture,
                                      userName:
                                          userName == '' || userName == null
                                              ? user!.email!.substring(0, 8)
                                              : userName,
                                      uid: user!.uid,
                                      email: email,
                                      mode: ProfileMode.display))),
                          child: Wrap(
                            children: [
                              isImageNetwork == true
                                  ? Hero(
                                      tag: 'network_image_hero',
                                      child: Image.network(
                                        profilePicture ??
                                            'assets/profile_pictures/Profile_Picture_Male.png',
                                        scale: 40,
                                      ),
                                    )
                                  : Hero(
                                      tag: 'asset_image_hero',
                                      child: Image.asset(
                                        profilePicture ??
                                            'assets/profile_pictures/Profile_Picture_Male.png',
                                        scale: 40,
                                      ),
                                    ),
                              Hero(
                                tag: 'userName_hero',
                                child: userName == null || userName == ''
                                    ? Text(
                                        " ${user!.email!.substring(0, 8)} ",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      )
                                    : Text(
                                        ' $userName. ',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        Wrap(
                          children: [
                            const Text(
                              'You have ',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            TaskData(
                              numberOfTasks: numberOfTasks,
                            ),
                            const Text(
                              ', and ',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            SchedulesData(
                              numberOfSchedules: numberOfSchedules,
                            ),
                            _focusedDay.isAfter(DateTime(today.year,
                                        today.month, today.day, 0, 0, 0)) &&
                                    _focusedDay.isBefore(DateTime(today.year,
                                        today.month, today.day, 23, 59, 59))
                                ? const SizedBox()
                                : const Text(
                                    ' on ',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                            _focusedDay.isAfter(DateTime(today.year,
                                        today.month, today.day, 0, 0, 0)) &&
                                    _focusedDay.isBefore(DateTime(today.year,
                                        today.month, today.day, 23, 59, 59))
                                ? const Text(
                                    ' today. ',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                : Text(
                                    '${DateFormat('dd/MM').format(_focusedDay)}. ',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                            numberOfSchedules == 0 &&
                                    numberOfTasks == 0 &&
                                    dates.isEmpty
                                ? Wrap(
                                    children: [
                                      const Text(
                                        'You are ',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      const Text(
                                        'Free ',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      _focusedDay.isAfter(DateTime(
                                                  today.year,
                                                  today.month,
                                                  today.day,
                                                  0,
                                                  0,
                                                  0)) &&
                                              _focusedDay.isBefore(DateTime(
                                                  today.year,
                                                  today.month,
                                                  today.day,
                                                  23,
                                                  59,
                                                  59))
                                          ? const SizedBox()
                                          : const Text(
                                              'on ',
                                              style: TextStyle(fontSize: 18),
                                            ),
                                      _focusedDay.isAfter(DateTime(
                                                  today.year,
                                                  today.month,
                                                  today.day,
                                                  0,
                                                  0,
                                                  0)) &&
                                              _focusedDay.isBefore(DateTime(
                                                  today.year,
                                                  today.month,
                                                  today.day,
                                                  23,
                                                  59,
                                                  59))
                                          ? const Text(
                                              'today. 🚀',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700),
                                            )
                                          : Text(
                                              '${DateFormat('dd/MM').format(_focusedDay)}.',
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                    ],
                                  )
                                : Wrap(
                                    children: [
                                      const Text(
                                        'You are mostly ',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      const Text(
                                        'Free ',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      const Text(
                                        'after ',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      dates.isNotEmpty
                                          ? Text(
                                              "${DateFormat('h:mm a').format(dates.last)}.",
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700),
                                            )
                                          : const Text(
                                              'now. 🚀',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                    ],
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 14,
            ),
            // Calendar to check and change the date of the events and tasks shown on homepage
            TableCalendar(
              focusedDay: _focusedDay,
              headerVisible: false,
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(fontWeight: FontWeight.w500)),
              availableCalendarFormats: const {
                CalendarFormat.week: 'Week',
              },
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
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
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(
                color: Colors.grey[200],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            numberOfSchedules == 0 && numberOfTasks == 0
                ? SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 14.0, right: 14.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Image(
                                height: 200,
                                width: 200,
                                image: AssetImage(
                                    'assets/images/allCompletedBackground.png'),
                              ),
                            ),
                            Text(
                              'Phew! Take a break',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              'Click on the + icon to add a new task, schedule an event and more.',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: DashboardCardLayout(
                        numberOfTasks: numberOfTasks,
                        numberOfSchedules: numberOfSchedules,
                        focusedDay: _focusedDay),
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
      // Add new object floating button
      floatingActionButton: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: () async {
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
                        child: const Column(
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Basic types of objects',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Expanded(child: TypesOfObjects()),
                            Text(
                              'More types of objects will be added soon...',
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : showMyCustomModalBottomSheet(context);
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
