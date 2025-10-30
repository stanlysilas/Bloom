import 'dart:io';

import 'package:bloom/components/events_tile.dart';
import 'package:calendar_view/calendar_view.dart' as cv;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SchedulesScreen extends StatefulWidget {
  const SchedulesScreen({super.key});

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  // Required variables
  final user = FirebaseAuth.instance.currentUser;
  final eventController = cv.EventController();
  late TextEditingController searchController;
  final searchFocusNode = FocusNode();
  bool toggleSearch = false;
  List<DocumentSnapshot> searchResults = [];
  late BannerAd bannerAd;
  bool isAdLoaded = false;
  String sortValue = 'Recent';

  // Method to initialize the required variables and methods
  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    searchController.addListener(onSearchChanged);
    // initBannerAd();
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

  Stream<QuerySnapshot> fetchEventsForDay() {
    final dateTime = DateTime.now();
    final todayStart =
        DateTime(dateTime.year, dateTime.month, dateTime.day, 0, 0, 0);
    final todayEnd =
        DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59);
    if (sortValue == 'Recent') {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('events')
          .where('isAttended', isEqualTo: false)
          .orderBy('eventStartDateTime', descending: true)
          .snapshots();
    } else if (sortValue == 'Oldest') {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('events')
          .where('isAttended', isEqualTo: false)
          .orderBy('eventStartDateTime', descending: false)
          .snapshots();
    } else if (sortValue == 'Attended') {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('events')
          .where('isAttended', isEqualTo: true)
          .orderBy('eventStartDateTime', descending: true)
          .snapshots();
    } else if (sortValue == 'Today') {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('events')
          .where('isAttended', isEqualTo: true)
          .where('eventStartDateTime', isGreaterThanOrEqualTo: todayStart)
          .where('eventEndDateTime', isLessThanOrEqualTo: todayEnd)
          .orderBy('eventStartDateTime', descending: true)
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('events')
          .where('isAttended', isEqualTo: false)
          .orderBy('eventStartDateTime', descending: true)
          .snapshots();
    }
  }

  void stateUpdate() {
    setState(() {});
  }

  // Banner ADs initialization method
  void initBannerAd() {
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
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Row(
                spacing: 8,
                children: [
                  // Default button
                  RawChip(
                    backgroundColor: sortValue != 'Recent'
                        ? Theme.of(context).colorScheme.surfaceVariant
                        : Theme.of(context).colorScheme.secondaryContainer,
                    side: BorderSide.none,
                    labelStyle: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                    iconTheme: IconThemeData(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer),
                    onPressed: () {
                      setState(() {
                        sortValue = 'Recent';
                      });
                    },
                    avatar: Icon(sortValue != 'Recent'
                        ? Icons.filter_list_off_rounded
                        : Icons.check_rounded),
                    label: Text('Default'),
                  ),
                  // Custom filters button
                  RawChip(
                    backgroundColor: sortValue != 'Recent'
                        ? Theme.of(context).colorScheme.secondaryContainer
                        : Theme.of(context).colorScheme.surfaceVariant,
                    side: BorderSide.none,
                    labelStyle: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                    iconTheme: IconThemeData(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer),
                    onPressed: () {
                      // Functionality to show the filter and other options as a modal bottom sheet
                      showAdaptiveDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog.adaptive(
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              title: const Text('Filters'),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 8),
                              content: StatefulBuilder(builder:
                                  (BuildContext context, StateSetter setState) {
                                return SingleChildScrollView(
                                  child: SizedBox(
                                    height: 260,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Today button
                                        ListTile(
                                          dense: true,
                                          minVerticalPadding: 0,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 4),
                                          leading: Radio.adaptive(
                                              value: 'Today',
                                              groupValue: sortValue,
                                              onChanged: (String? sortvalue) {
                                                setState(() {
                                                  sortValue = sortvalue!;
                                                });
                                                stateUpdate();
                                              }),
                                          horizontalTitleGap: 0,
                                          title: Text(
                                            'Today',
                                            textAlign: TextAlign.start,
                                          ),
                                          subtitle: Text(
                                              'Show only the events for today'),
                                          titleTextStyle: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color),
                                          subtitleTextStyle:
                                              TextStyle(color: Colors.grey),
                                          onTap: () {
                                            setState(() {
                                              sortValue = 'Today';
                                            });
                                            stateUpdate();
                                          },
                                        ),
                                        // Recent button
                                        ListTile(
                                          dense: true,
                                          minVerticalPadding: 0,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 4),
                                          leading: Radio.adaptive(
                                              value: 'Recent',
                                              groupValue: sortValue,
                                              onChanged: (String? sortvalue) {
                                                setState(() {
                                                  sortValue = sortvalue!;
                                                });
                                                stateUpdate();
                                              }),
                                          horizontalTitleGap: 0,
                                          title: Text(
                                            'Recent',
                                            textAlign: TextAlign.start,
                                          ),
                                          subtitle: Text(
                                              'Sort the tasks from recent to oldest'),
                                          titleTextStyle: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color),
                                          subtitleTextStyle:
                                              TextStyle(color: Colors.grey),
                                          onTap: () {
                                            setState(() {
                                              sortValue = 'Recent';
                                            });
                                            stateUpdate();
                                          },
                                        ),
                                        // Oldest button
                                        ListTile(
                                          dense: true,
                                          minVerticalPadding: 0,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 4),
                                          leading: Radio.adaptive(
                                              value: 'Oldest',
                                              groupValue: sortValue,
                                              onChanged: (String? sortvalue) {
                                                setState(() {
                                                  sortValue = sortvalue!;
                                                });
                                                stateUpdate();
                                              }),
                                          horizontalTitleGap: 0,
                                          title: Text(
                                            'Oldest',
                                            textAlign: TextAlign.start,
                                          ),
                                          subtitle: Text(
                                              'Sort the events from oldest to recent'),
                                          titleTextStyle: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color),
                                          subtitleTextStyle:
                                              TextStyle(color: Colors.grey),
                                          onTap: () {
                                            setState(() {
                                              sortValue = 'Oldest';
                                            });
                                            stateUpdate();
                                          },
                                        ),
                                        // Attended button
                                        ListTile(
                                          dense: true,
                                          minVerticalPadding: 0,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 4),
                                          leading: Radio.adaptive(
                                              value: 'Attended',
                                              groupValue: sortValue,
                                              onChanged: (String? sortvalue) {
                                                setState(() {
                                                  sortValue = sortvalue!;
                                                });
                                                stateUpdate();
                                              }),
                                          horizontalTitleGap: 0,
                                          title: Text(
                                            'Attended',
                                            textAlign: TextAlign.start,
                                          ),
                                          subtitle:
                                              Text('Show only attended events'),
                                          titleTextStyle: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color),
                                          subtitleTextStyle:
                                              TextStyle(color: Colors.grey),
                                          onTap: () {
                                            setState(() {
                                              sortValue = 'Attended';
                                            });
                                            stateUpdate();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              actions: [
                                // Cancel button
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    return;
                                  },
                                  child: Text('Close'),
                                ),
                              ],
                            );
                          });
                    },
                    avatar: Icon(sortValue != 'Recent'
                        ? Icons.check_rounded
                        : Icons.filter_list_rounded),
                    label: Text('Filter'),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            StreamBuilder<QuerySnapshot>(
              stream: fetchEventsForDay(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Skeletonizer(
                    enabled: true,
                    containersColor: Theme.of(context).primaryColorLight,
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
                  ).animate().fade(delay: const Duration(milliseconds: 50));
                }
                if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: MediaQuery.of(context).size.width,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 14.0, right: 14.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(
                            height: 250,
                            width: 250,
                            image: AssetImage(
                                'assets/images/allCompletedBackground.png'),
                          ),
                          Text(
                            'Finally! Attended your events',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w500),
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
                    child: Text('Encountered an error while retrieving events'),
                  ).animate().fadeIn(
                        duration: const Duration(milliseconds: 500),
                      );
                }
                final tasksList = snapshot.data!.docs;
                return ListView.builder(
                    itemCount: tasksList.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final doc = tasksList[index];
                      final eventId = doc['eventId'];
                      final eventTitle = doc['eventName'];
                      final eventDetails = doc['eventNotes'];
                      final Timestamp endDateTime = doc['eventEndDateTime'];
                      final DateTime eventEndDateTime = endDateTime.toDate();
                      final Timestamp startDateTime = doc['eventStartDateTime'];
                      final DateTime eventStartDateTime =
                          startDateTime.toDate();
                      final String color = doc['eventColorCode'] ?? '';
                      final Color eventColorCode =
                          Color(int.parse(color, radix: 16) + 0xFF000000);
                      final int? eventUniqueId = doc['eventUniqueId'];
                      final bool isAttended = doc['isAttended'] ?? false;
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
                    });
              },
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     // Check if the platform is windows or android
      //     // And display a sheet if android and dialog if windows
      //     Platform.isWindows
      //         ? showDialog(
      //             context: context,
      //             builder: (context) {
      //               return Dialog(
      //                 backgroundColor:
      //                     Theme.of(context).scaffoldBackgroundColor,
      //                 child: SizedBox(
      //                   width: MediaQuery.of(context).size.width / 2,
      //                   child: Column(
      //                     children: [
      //                       const SizedBox(
      //                         height: 20,
      //                       ),
      //                       AddEventModalSheet(currentDateTime: _focusedDay!),
      //                     ],
      //                   ),
      //                 ),
      //               );
      //             },
      //           )
      //         :
      //         // Add new event process
      //         showModalBottomSheet(
      //             context: context,
      //             isScrollControlled: true,
      //             useSafeArea: true,
      //             backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      //             builder: (BuildContext context) {
      //               return AddEventModalSheet(
      //                 currentDateTime: _focusedDay!,
      //               );
      //             },
      //             showDragHandle: true,
      //           );
      //   },
      //   backgroundColor: Theme.of(context).primaryColor,
      //   child: Icon(
      //     Icons.add,
      //     size: 24,
      //     color: Theme.of(context).textTheme.bodyMedium?.color,
      //   ),
      // ).animate().scaleXY(
      //       curve: Curves.easeInOutBack,
      //       delay: const Duration(
      //         milliseconds: 1000,
      //       ),
      //     ),
    );
  }
}

class Event {
  final String id;
  final String title;
  final String description;

  Event({required this.id, required this.title, required this.description});
}
