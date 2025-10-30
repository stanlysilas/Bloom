import 'dart:io';

import 'package:bloom/components/events_tile.dart';
import 'package:bloom/components/habit_tile.dart';
// import 'package:bloom/components/mybuttons.dart';
import 'package:bloom/components/tasktile.dart';
import 'package:bloom/screens/eventstabview.dart';
import 'package:bloom/screens/habitstabview.dart';
import 'package:bloom/screens/taskstabview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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
  bool toggleSearch = false;
  List<Map<String, dynamic>> searchResults = [];
  late BannerAd bannerAd;
  bool isAdLoaded = false;
  int? tasksStreak;
  int? eventsStreak;
  List<DateTime> tasksStreaksDates = [];
  List<DateTime> eventsStreaksDates = [];
  List<DateTime> allStreaksDates = [];
  bool? isTodayCompleted;
  bool? clearStreaks;
  late final TabController tabController;
  late int tabIndex;
  String searchObject = 'tasks';

  @override
  void initState() {
    migrateLowercaseFields('tasks');
    migrateLowercaseFields('habits');
    migrateLowercaseFields('events');
    searchController = TextEditingController();
    searchController.addListener(onSearchChanged);
    // initBannerAd();
    super.initState();
    tabController = TabController(
        initialIndex: widget.tabIndex ?? 0, length: 3, vsync: this);
    setState(() {
      tabIndex = tabController.index;
    });
  }

  // To update the state
  void stateUpdate() {
    setState(() {});
  }

// Banner ADs initialization method
  void initBannerAd() {
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

  /// Migrate the Title's of old Tasks, Habits and Events to support
  /// the new Fuzzy search logic.
  Future<void> migrateLowercaseFields(String type) async {
    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection(type);

    final snapshot = await collection.get();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final fieldName = {
        'tasks': 'taskName',
        'habits': 'habitName',
        'events': 'eventName',
      }[type];

      if (fieldName != null &&
          data[fieldName] != null &&
          data['${fieldName}_lower'] == null) {
        await doc.reference.update({
          '${fieldName}_lower': data[fieldName].toString().toLowerCase(),
        });
      }
    }
  }

  void onSearchChanged() {
    searchFirestore(searchController.text);
  }

  /// Search the[FirebaseFirestore] for the user query.
  /// [query] may be 'tasks', 'habits' or 'events'.
  Future<List<Map<String, dynamic>>> searchFirestore(String query) async {
    if (query.isEmpty) {
      setState(() => searchResults = []);
      return [];
    }

    final normalized = query.toLowerCase(); // normalize for fuzzy match
    QuerySnapshot<Map<String, dynamic>> querySnapshot;
    List<Map<String, dynamic>> tempResults = [];

    try {
      final collection = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection(searchObject);

      String fieldName;
      if (searchObject == 'tasks') {
        fieldName = 'taskName';
      } else if (searchObject == 'habits') {
        fieldName = 'habitName';
      } else if (searchObject == 'events') {
        fieldName = 'eventName';
      } else {
        setState(() => searchResults = []);
        return [];
      }

      // First try the new lowercase field (for newer docs)
      querySnapshot = await collection
          .where('${fieldName}_lower', isGreaterThanOrEqualTo: normalized)
          .where('${fieldName}_lower', isLessThanOrEqualTo: '$normalized\uf8ff')
          .get();

      tempResults = querySnapshot.docs.map((doc) => doc.data()).toList();

      // If no results, fallback to old case-sensitive field
      if (tempResults.isEmpty) {
        querySnapshot = await collection
            .where(fieldName, isGreaterThanOrEqualTo: query)
            .where(fieldName, isLessThanOrEqualTo: '$query\uf8ff')
            .get();

        tempResults = querySnapshot.docs.map((doc) => doc.data()).toList();
      }

      // Optional: secondary fuzzy filter (client-side contains check)
      tempResults = tempResults.where((data) {
        final title = (data['${fieldName}_lower'] ??
                data[fieldName]?.toString().toLowerCase() ??
                '')
            .toString();
        return title.contains(normalized);
      }).toList();

      setState(() => searchResults = tempResults);
      return tempResults;
    } catch (e) {
      debugPrint('Search error: $e');
      setState(() => searchResults = []);
      return [];
    }
  }

  @override
  void dispose() {
    super.dispose();
    searchController.removeListener(onSearchChanged);
    tabController.dispose();
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
          // FIXME: ACCIDENTALLY REMOVED THE LOGIC FOR CAPTURING COMPLETED DATES
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Container(
          //       decoration: BoxDecoration(
          //         color: isTodayCompleted == true
          //             ? Theme.of(context).colorScheme.secondary
          //             : Theme.of(context).colorScheme.errorContainer,
          //         borderRadius: BorderRadius.circular(12),
          //       ),
          //       child: IconButton(
          //         onPressed: () => showStreakDialogBox(
          //             context,
          //             'tasksCompletedDates',
          //             'Tasks',
          //             isTodayCompleted!,
          //             clearStreaks),
          //         icon: Row(
          //           children: [
          //             isTodayCompleted == true
          //                 ? const Text('🔥')
          //                 : clearStreaks == false
          //                     ? const Text('⚠️')
          //                     : const Text('❄️'),
          //             const SizedBox(
          //               width: 4,
          //             ),
          //             tasksStreak.toString().isEmpty || tasksStreak == null
          //                 ? Text(
          //                     '0',
          //                     style: TextStyle(fontWeight: FontWeight.w600),
          //                   )
          //                 : Text(
          //                     tasksStreak.toString(),
          //                     style: TextStyle(
          //                         fontSize: 16, fontWeight: FontWeight.w600),
          //                   )
          //           ],
          //         ),
          //       )),
          // ),
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
                    autoFocus: true,
                    padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 16.0)),
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(16))),
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
                    hintText: 'Search $searchObject',
                    elevation: const WidgetStatePropertyAll(0),
                  ),
                ))
            : TabBar(
                controller: tabController,
                onTap: (value) {
                  setState(() {
                    tabIndex = value;
                  });
                },
                dividerColor: Colors.transparent,
                tabs: const [
                    Tab(
                      text: 'Tasks',
                    ),
                    Tab(
                      text: 'Habits',
                    ),
                    Tab(
                      text: 'Events',
                    )
                  ]),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            toggleSearch == true
                ? SizedBox(
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
                                    ? Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainer,
                                side: BorderSide.none,
                                avatar: searchObject == 'tasks'
                                    ? Icon(Icons.check_rounded)
                                    : Icon(Icons.filter_list_off_rounded),
                                iconTheme: IconThemeData(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer),
                                label: Text('Tasks'),
                                labelStyle: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer),
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
                                    ? Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainer,
                                side: BorderSide.none,
                                avatar: searchObject == 'habits'
                                    ? Icon(Icons.check_rounded)
                                    : Icon(Icons.filter_list_off_rounded),
                                iconTheme: IconThemeData(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer),
                                label: Text('Habits'),
                                labelStyle: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer),
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
                                    ? Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainer,
                                side: BorderSide.none,
                                avatar: searchObject == 'events'
                                    ? Icon(Icons.check_rounded)
                                    : Icon(Icons.filter_list_off_rounded),
                                iconTheme: IconThemeData(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer),
                                label: Text('Events'),
                                labelStyle: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer),
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
                                  padding:
                                      EdgeInsets.only(left: 14.0, right: 14.0),
                                  child: Text(
                                    'Enter the title of an object to search for it',
                                    style: TextStyle(color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                )),
                              )
                            : searchResults.isEmpty
                                ? SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.5,
                                    width: MediaQuery.of(context).size.width,
                                    child: const Padding(
                                      padding: EdgeInsets.only(
                                          left: 14.0, right: 14.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image(
                                            height: 250,
                                            width: 250,
                                            image: AssetImage(
                                                'assets/images/searchEmpty.png'),
                                          ),
                                          Text(
                                            'No results',
                                            style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w500),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          SizedBox(
                                            width: 200,
                                            child: Text(
                                              'Try adjusting your search or using a different search term.',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 14,
                                          )
                                        ],
                                      ),
                                    ))
                                : const Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 16.0, horizontal: 14),
                                    child: Text(
                                      'Showing matching results',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500),
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
                                  List completedDates =
                                      doc['completedDates'] ?? [];
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
                                  final String color =
                                      doc['eventColorCode'] ?? '';
                                  final Color eventColorCode = Color(
                                      int.parse(color, radix: 16) + 0xFF000000);
                                  final int? eventUniqueId =
                                      doc['eventUniqueId'];
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
                                    child: Text(
                                        'No results for this search query'),
                                  );
                                }
                              }),
                        ),
                      ],
                    ),
                  )
                // TabBarView of all the goals (Tasks, Habits, Events)
                : SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        // Tasks tab view
                        Taskstabview(),
                        // Habits tab view
                        Habitstabview(),
                        // Schedules tab view
                        SchedulesScreen(),
                      ],
                    ),
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
    );
  }
}
