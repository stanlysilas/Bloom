import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:bloom/components/book_card.dart';
import 'package:bloom/components/entries_tile.dart';
import 'package:bloom/components/mybuttons.dart';
import 'package:bloom/components/mytextfield.dart';
import 'package:bloom/screens/custom_templates_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:table_calendar/table_calendar.dart';

class EntriesScreen extends StatefulWidget {
  const EntriesScreen({super.key});

  @override
  State<EntriesScreen> createState() => _EntriesScreenState();
}

class _EntriesScreenState extends State<EntriesScreen> {
  // Required variables
  final user = FirebaseAuth.instance.currentUser;
  final searchController = TextEditingController();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  var _focusedDay = DateTime.now();
  var _selectedDay = DateTime.now();
  bool toggleDayView = false;
  bool toggleSearch = false;
  int? numberOfBooks;
  int? numberOfEntries;
  List<DocumentSnapshot> searchResults = [];
  String sortValue = 'Recents';
  final now = DateTime.now();
  String date = '';
  String time = '';
  String? subscriptionPlan;
  late BannerAd bannerAd;
  bool isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    searchController.addListener(onSearchChanged);
    fetchEntriesForCalendar();
    // Formate intial date and time to strings
    setState(() {
      date = DateFormat('dd-MM-yyyy').format(now);
      time = DateFormat('h:mm a').format(now);
    });
    fetchAccountData();
    // initBannerAd();
  }

  // Fetch accountData
  void fetchAccountData() async {
    final docRef =
        FirebaseFirestore.instance.collection('users').doc(user?.uid);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      setState(() {
        subscriptionPlan = data?['subscriptionPlan'] ?? 'free';
      });
    } else {}
  }

  // Banner ADs initialization method
  initBannerAd() {
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: "ca-app-pub-5607290715305671/5324741224",
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
              closeIconColor: Theme.of(context).textTheme.bodyMedium?.color,
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

  void onSearchChanged() {
    searchFirestore(searchController.text);
  }

  Future searchFirestore(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return searchResults;
    } else {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('entries')
          .where('mainEntryTitle', isGreaterThanOrEqualTo: query)
          .where('mainEntryTitle', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      setState(() {
        searchResults = snapshot.docs;
      });
    }
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  Stream<QuerySnapshot> fetchEntriesForDay(DateTime date) {
    var dayStart =
        DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day, 0, 0, 0);
    var dayEnd = DateTime(
        _focusedDay.year, _focusedDay.month, _focusedDay.day, 23, 59, 59);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('entries')
        .where('addedOn', isGreaterThanOrEqualTo: dayStart)
        .where('addedOn', isLessThanOrEqualTo: dayEnd)
        .orderBy('addedOn', descending: true)
        .snapshots();
  }

  // Method to retrieve the books
  Stream<List<Map<String, dynamic>>> fetchBooks() {
    Stream<QuerySnapshot<Map<String, dynamic>>> query;
    query = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('books')
        .orderBy('addedOn', descending: true)
        .snapshots();

    return query.map((querySnapshot) {
      numberOfBooks = querySnapshot.docs.length;
      return querySnapshot.docs
          .map((doc) => doc.data()..['bookId'] = doc.id)
          .toList();
    });
  }

  // Method to retrieve the documents of entries collection to display them
  Stream<List<Map<String, dynamic>>> fetchEntries() {
    Stream<QuerySnapshot<Map<String, dynamic>>> query;
    if (sortValue == 'Recents') {
      query = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('entries')
          .orderBy('addedOn', descending: true)
          .snapshots();
    } else if (sortValue == 'Oldest') {
      query = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('entries')
          .orderBy('addedOn', descending: false)
          .snapshots();
    } else if (sortValue == 'Favorites') {
      query = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('entries')
          .where('isFavorite', isEqualTo: true)
          .snapshots();
    } else if (sortValue == 'Locked') {
      query = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('entries')
          .where('isEntryLocked', isEqualTo: true)
          .snapshots();
    } else {
      query = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('entries')
          .orderBy('addedOn', descending: true)
          .snapshots();
    }

    return query.map((querySnapshot) {
      numberOfEntries = querySnapshot.docs.length;
      return querySnapshot.docs
          .map((doc) => doc.data()..['mainEntryId'] = doc.id)
          .toList();
    });
  }

  Map<DateTime, List<Entry>> _entries = {};

  // fetch tasks for displaying dot on the calendar
  Future<void> fetchEntriesForCalendar() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('entries')
        .get();

    Map<DateTime, List<Entry>> entries = {};

    for (var doc in snapshot.docs) {
      Timestamp timestamp = doc['addedOn'];
      DateTime dateTime = timestamp.toDate();
      DateTime date = normalizeDate(dateTime);
      Entry entry = Entry(
        id: doc.id,
      );

      // Group events by date
      if (entries[date] == null) {
        entries[date] = [];
      }
      entries[date]!.add(entry);
    }

    setState(() {
      _entries = entries;
    });
  }

  DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day, 0, 0, 0);
  }

  // Function to convert Quill Delta to RichText
  RichText quillDeltaToRichText(String deltaJson) {
    final Delta delta = Delta.fromJson(jsonDecode(deltaJson));
    final List<TextSpan> children = [];

    for (final op in delta.toList()) {
      final attributes = op.attributes ?? {};
      final text = op.value;

      TextStyle textStyle = const TextStyle();

      if (attributes.containsKey('bold')) {
        textStyle = textStyle.copyWith(fontWeight: FontWeight.bold);
      }
      if (attributes.containsKey('italic')) {
        textStyle = textStyle.copyWith(fontStyle: FontStyle.italic);
      }
      if (attributes.containsKey('underline')) {
        textStyle = textStyle.copyWith(decoration: TextDecoration.underline);
      }
      if (attributes.containsKey('color')) {
        textStyle = textStyle.copyWith(
            color:
                Color(int.parse(attributes['color'].substring(1), radix: 16)));
      }

      children.add(TextSpan(text: text, style: textStyle));
    }

    return RichText(text: TextSpan(children: children));
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
        title: const Text(
          'Entries',
          style: TextStyle(fontWeight: FontWeight.w500),
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
                    : searchController;
              },
              icon: const Icon(Icons.search)),
          IconButton(
            onPressed: () {
              setState(() {
                toggleDayView = !toggleDayView;
              });
              fetchEntriesForDay(_focusedDay);
            },
            icon: toggleDayView
                ? const Icon(Iconsax.book)
                : const Icon(Iconsax.calendar_1),
          ),
        ],
      ),
      body: toggleSearch
          ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: MyTextfield(
                      controller: searchController,
                      hintText: 'Search title of Entry (Case Sensitive)',
                      obscureText: false,
                      textInputType: TextInputType.text,
                      autoFocus: false,
                    ),
                  ),
                  searchResults.isEmpty && searchController.text.isEmpty
                      ? const Center(
                          child: Padding(
                          padding: EdgeInsets.only(left: 14.0, right: 14.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Enter the title of an entry to search for it. Searches are case sensitive.',
                                style: TextStyle(color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "Eg: If an entry title is 'Entry title', then it won't be shown if you search 'entry title'",
                                style: TextStyle(color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ))
                      : searchResults.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 16.0, horizontal: 14),
                                child: Text(
                                  'No matching results',
                                  style: TextStyle(fontWeight: FontWeight.w500),
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
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot doc = searchResults[index];
                          String entryDescription = doc['mainEntryDescription'];
                          String entryTitle = doc['mainEntryTitle'] ?? '';
                          String entryId = doc['mainEntryId'];
                          List entryChildren = doc['children'];
                          String entryBackgroundImageUrl =
                              doc['backgroundImageUrl'];
                          String entryEmoji = doc['mainEntryEmoji'];
                          List entryAttachments = doc['attachments'];
                          String entryType = doc['mainEntryType'];
                          bool entryHasChildren = doc['hasChildren'];
                          // Timestamp onlyDate = doc['dueDate'];
                          bool entryIsFavorite = doc['isFavorite'];
                          final Timestamp timestamp = doc['addedOn'];
                          final Timestamp datetime = doc['dateTime'];
                          final DateTime entryDate = timestamp.toDate();
                          final DateTime dateTime = datetime.toDate();
                          final DateTime addedOn = entryDate;
                          final isSynced = doc['synced'];
                          String date =
                              DateFormat('dd-MM-yyyy').format(dateTime);
                          Timestamp onlyTime = doc['dateTime'];
                          DateTime timeDate = onlyTime.toDate();
                          String time = DateFormat('h:mm a').format(timeDate);
                          final isEntryLocked = doc['isEntryLocked'] ?? false;
                          if (searchResults.isEmpty) {
                            return const Center(
                              child: Text(
                                'There is no matching data',
                              ),
                            );
                          } else {
                            return Column(
                              children: [
                                EntriesTile(
                                  innerPadding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 4),
                                  content: entryDescription,
                                  title: entryTitle,
                                  emoji: entryEmoji,
                                  date: date,
                                  time: time,
                                  id: entryId,
                                  type: entryType,
                                  backgroundImageUrl: entryBackgroundImageUrl,
                                  attachments: entryAttachments,
                                  hasChildren: entryHasChildren,
                                  children: entryChildren,
                                  isFavorite: entryIsFavorite,
                                  addedOn: addedOn,
                                  dateTime: dateTime,
                                  isSynced: isSynced,
                                  isEntryLocked: isEntryLocked,
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
            )
          : toggleDayView
              ? SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display the calendar at top
                      TableCalendar(
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
                            weekdayStyle:
                                TextStyle(fontWeight: FontWeight.w500)),
                        calendarStyle: CalendarStyle(
                          isTodayHighlighted: false,
                          todayDecoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
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
                                  .bodyMedium
                                  ?.color),
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
                          // Return the list of entries for the given day
                          return _entries[normalizeDate(day)] ?? [];
                        },
                        availableCalendarFormats: const {
                          CalendarFormat.month: 'Week',
                          CalendarFormat.twoWeeks: 'Month',
                          CalendarFormat.week: '2 Weeks',
                        },
                        calendarFormat: _calendarFormat,
                        onFormatChanged: (format) {
                          return setState(() {
                            _calendarFormat = format;
                          });
                        },
                        onDaySelected: (selectedDay, focusedDay) async {
                          return onDaySelected(selectedDay, focusedDay);
                        },
                      ).animate().fadeIn(
                            duration: const Duration(
                              milliseconds: 500,
                            ),
                          ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.0),
                        child: Divider(),
                      ),
                      // Display the entries(notes) matching to the selected or focused day
                      StreamBuilder<QuerySnapshot>(
                        stream: fetchEntriesForDay(_focusedDay),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Skeletonizer(
                              enabled: true,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14.0),
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
                              ),
                            )
                                .animate()
                                .fade(delay: const Duration(milliseconds: 50));
                          }
                          if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: SizedBox(
                                height: MediaQuery.of(context).size.height,
                                child: const Padding(
                                  padding:
                                      EdgeInsets.only(left: 14.0, right: 14.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image(
                                        height: 200,
                                        width: 200,
                                        image: AssetImage(
                                            'assets/images/allCompletedBackground.png'),
                                      ),
                                      Text(
                                        'No entries made on this day',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        'Click on the + icon to make a new entry.',
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ).animate().fadeIn(
                                    delay: const Duration(milliseconds: 100),
                                  ),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                  'Encountered an error while retrieving entries for ${DateFormat.yMMMMd().format(_focusedDay)}'),
                            ).animate().fadeIn(
                                  duration: const Duration(milliseconds: 500),
                                );
                          }
                          final entries = snapshot.data!.docs;
                          return SizedBox(
                            height: MediaQuery.of(context).size.height,
                            child: ListView.builder(
                                itemCount: entries.length,
                                itemBuilder: (context, index) {
                                  final entry = entries[index];
                                  final entryDescription =
                                      entry['mainEntryDescription'] ?? '{}';
                                  final entryTitle =
                                      entry['mainEntryTitle'] ?? '';
                                  final entryBackgroundImageUrl =
                                      entry['backgroundImageUrl'] ?? '';
                                  final entryId = entry['mainEntryId'] ?? '';
                                  final entryType =
                                      entry['mainEntryType'] ?? '';
                                  final entryEmoji =
                                      entry['mainEntryEmoji'] ?? '';
                                  final entryAttachments =
                                      entry['attachments'] ?? [];
                                  final entryChildren = entry['children'];
                                  final entryHasChildren = entry['hasChildren'];
                                  final Timestamp timestamp = entry['addedOn'];
                                  final Timestamp datetime = entry['dateTime'];
                                  final DateTime entryDate = timestamp.toDate();
                                  final DateTime dateTime = datetime.toDate();
                                  final DateTime addedOn = entryDate;
                                  final entryIsFavorite = entry['isFavorite'];
                                  final date = DateFormat('dd-MM-yyyy')
                                      .format(entryDate);
                                  final entryTime =
                                      entry['dateTime']?.toDate() ?? '';
                                  final time =
                                      DateFormat('h:mm a').format(entryTime);
                                  final isSynced = entry['synced'];
                                  final isEntryLocked =
                                      entry['isEntryLocked'] ?? false;
                                  return Column(
                                    children: [
                                      EntriesTile(
                                        innerPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 4),
                                        content: entryDescription,
                                        title: entryTitle,
                                        emoji: entryEmoji,
                                        date: date,
                                        time: time,
                                        id: entryId,
                                        type: entryType,
                                        backgroundImageUrl:
                                            entryBackgroundImageUrl,
                                        attachments: entryAttachments,
                                        hasChildren: entryHasChildren,
                                        children: entryChildren,
                                        isFavorite: entryIsFavorite,
                                        addedOn: addedOn,
                                        dateTime: dateTime,
                                        isSynced: isSynced,
                                        isEntryLocked: isEntryLocked,
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
                                }),
                          );
                        },
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recently added entries title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            // Show a modal bottom sheet for more filtering and other options
                            showModalBottomSheet(
                                showDragHandle: true,
                                backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                isScrollControlled: true,
                                isDismissible: true,
                                useSafeArea: true,
                                constraints: BoxConstraints(
                                  minWidth: double.maxFinite,
                                  maxHeight:
                                      MediaQuery.of(context).size.height * 0.9,
                                ),
                                context: context,
                                builder: (context) {
                                  return Column(
                                    children: [
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14),
                                        child: ExtraOptionsButton(
                                          icon: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: Theme.of(context)
                                                    .primaryColorLight,
                                              ),
                                              child:
                                                  const Icon(Iconsax.filter)),
                                          iconLabelSpace: 8,
                                          label: 'Filter by',
                                          labelStyle: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16),
                                          endIcon: PopupMenuButton(
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            popUpAnimationStyle: AnimationStyle(
                                                duration: const Duration(
                                                    milliseconds: 500)),
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: 'recent entries',
                                                onTap: () {
                                                  setState(() {
                                                    sortValue = 'Recents';
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  'Recents',
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.color),
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'oldest',
                                                child: Text(
                                                  'Oldest',
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.color),
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    sortValue = 'Oldest';
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              PopupMenuItem(
                                                value: 'favorites',
                                                child: Text(
                                                  'Favorites',
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.color),
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    sortValue = 'Favorites';
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              PopupMenuItem(
                                                value: 'locked',
                                                child: Text(
                                                  'Locked',
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.color),
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    sortValue = 'Locked';
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                            child: Row(
                                              children: [
                                                Text(sortValue),
                                                const Icon(Icons
                                                    .arrow_drop_down_rounded)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                });
                          },
                          child: Container(
                            width: 70,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Theme.of(context).primaryColorDark),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(
                                  Iconsax.settings,
                                  size: 14,
                                ),
                                Text('Filters'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      StreamBuilder(
                          stream: fetchBooks(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Skeletonizer(
                                enabled: true,
                                child: SizedBox(
                                  height: 120,
                                  width: 120,
                                  child: Column(
                                    children: [
                                      Icon(Icons.abc),
                                      Text(
                                        'So this is the text of the title of the object here...',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                        maxLines: 1,
                                      ),
                                      Text(
                                        'So this is the text of the subtitle of the object here...',
                                        maxLines: 1,
                                      ),
                                      Text('End'),
                                    ],
                                  ),
                                ),
                              ).animate().fade(
                                  delay: const Duration(milliseconds: 50));
                            }
                            if (snapshot.hasData && snapshot.data!.isEmpty) {
                              return const SizedBox();
                            }
                            if (snapshot.hasError) {
                              return const Center(
                                child: Text(
                                    'Error occurred while fetching books...'),
                              );
                            } else {
                              final books = snapshot.data!;
                              return Container(
                                height: 140,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 4),
                                width: MediaQuery.of(context).size.width,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: books.length,
                                  itemBuilder: (context, index) {
                                    final book = books[index];
                                    final String bookId = book['bookId'];
                                    final String type = book['type'];
                                    final String bookIcon = book['bookEmoji'];
                                    final String bookTitle = book['bookTitle'];
                                    final String bookDescription =
                                        book['bookDescription'];
                                    final Timestamp timestamp = book['addedOn'];
                                    final DateTime addedOn = timestamp.toDate();
                                    final bool hasChildren =
                                        book['hasChildren'];
                                    return BookCard(
                                      type: type,
                                      isTemplate: false,
                                      hasChildren: hasChildren,
                                      dateTime: addedOn,
                                      bookId: bookId,
                                      emoji: bookIcon,
                                      title: bookTitle,
                                      description: bookDescription,
                                    );
                                  },
                                ),
                              );
                            }
                          }),
                      if (numberOfBooks != 0 || numberOfEntries != 0)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14.0),
                          child: Divider(),
                        ),
                      StreamBuilder<List<Map<String, dynamic>>>(
                          stream: fetchEntries(),
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
                            if (numberOfBooks == 0 && numberOfEntries == 0) {
                              return const SizedBox(
                                child: Padding(
                                  padding:
                                      EdgeInsets.only(left: 14.0, right: 14.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image(
                                        height: 200,
                                        width: 200,
                                        image: AssetImage(
                                            'assets/images/allCompletedBackground.png'),
                                      ),
                                      Text(
                                        'Make a new entry',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        'Click on the + icon to make a new note, document your life and more',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return const Center(
                                child: Text(
                                    'Error occurred while getting entries...'),
                              );
                            } else {
                              final entries = snapshot.data!;
                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: entries.length,
                                itemBuilder: (context, index) {
                                  final entry = entries[index];
                                  final entryDescription =
                                      entry['mainEntryDescription'];
                                  final entryTitle =
                                      entry['mainEntryTitle'] ?? '';
                                  final entryBackgroundImageUrl =
                                      entry['backgroundImageUrl'] ?? '';
                                  final entryId = entry['mainEntryId'] ?? '';
                                  final entryType =
                                      entry['mainEntryType'] ?? '';
                                  final entryEmoji =
                                      entry['mainEntryEmoji'] ?? '';
                                  final entryAttachments =
                                      entry['attachments'] ?? [];
                                  final entryChildren = entry['children'];
                                  final entryHasChildren = entry['hasChildren'];
                                  final Timestamp timestamp = entry['addedOn'];
                                  final Timestamp datetime = entry['dateTime'];
                                  final DateTime entryDate = timestamp.toDate();
                                  final DateTime dateTime = datetime.toDate();
                                  final DateTime addedOn = entryDate;
                                  final date = DateFormat('dd-MM-yyyy')
                                      .format(entryDate);
                                  final entryTime =
                                      entry['dateTime']?.toDate() ?? '';
                                  final entryIsFavorite = entry['isFavorite'];
                                  final time =
                                      DateFormat('h:mm a').format(entryTime);
                                  final isSynced = entry['synced'];
                                  final isEntryLocked =
                                      entry['isEntryLocked'] ?? false;
                                  return Column(
                                    children: [
                                      EntriesTile(
                                        innerPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 4),
                                        content: entryDescription,
                                        title: entryTitle,
                                        emoji: entryEmoji,
                                        date: date,
                                        time: time,
                                        id: entryId,
                                        type: entryType,
                                        backgroundImageUrl:
                                            entryBackgroundImageUrl ?? '',
                                        attachments: entryAttachments ?? [],
                                        hasChildren: entryHasChildren ?? false,
                                        children: entryChildren ?? [],
                                        isFavorite: entryIsFavorite ?? false,
                                        addedOn: addedOn,
                                        dateTime: dateTime,
                                        isSynced: isSynced,
                                        isEntryLocked: isEntryLocked,
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
                                },
                              );
                            }
                          }),
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
      floatingActionButton: InkWell(
        borderRadius: BorderRadius.circular(100),
        // onLongPress function to quickly go to the appropriate entry type
        // onLongPress: () {
        //   print('Long Pressed the add entry button');
        // },
        // onTap function to display the bottomSheet for types of entries
        onTap: () {
          showModalBottomSheet(
            context: context,
            showDragHandle: true,
            enableDrag: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            builder: (context) {
              return SafeArea(
                child: Column(
                  children: [
                    // Display all the basic objects
                    const Expanded(
                      child: TypesOfEntries(),
                    ),
                    // Display a button to more templates
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'More entry ',
                        ),
                        InkWell(
                          onTap: () {
                            if (subscriptionPlan == 'free') {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      icon: Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.payment_rounded,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color,
                                          )),
                                      title: const Text(
                                          'Upgrade to use templates'),
                                      titleTextStyle: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                                      ),
                                      titlePadding: const EdgeInsets.all(12),
                                      content: const Text(
                                        'To use custom templates, pomodoro and other such productivity features, you need to be on either the Pro or the Ultra subscription plans.',
                                        textAlign: TextAlign.center,
                                      ),
                                      actions: [
                                        // Button to cancel and close the dialog box
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          style: const ButtonStyle(
                                            foregroundColor:
                                                WidgetStatePropertyAll(
                                                    Colors.red),
                                          ),
                                          child: const Text('Cancel'),
                                        ),
                                        // Button to redirect to the subscriptions page
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          style: ButtonStyle(
                                            foregroundColor:
                                                WidgetStatePropertyAll(
                                                    Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.color),
                                          ),
                                          child: const Text('Upgrade'),
                                        ),
                                      ],
                                    );
                                  });
                            } else {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      const CustomTemplatesScreen()));
                            }
                          },
                          child: const Row(
                            children: [
                              Text(
                                'templates',
                                style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w700),
                              ),
                              Icon(
                                Icons.open_in_new_rounded,
                                size: 14,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8)
                  ],
                ),
              );
            },
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

class Entry {
  final String id;

  Entry({required this.id});
}
