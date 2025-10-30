import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:bloom/components/book_card.dart';
import 'package:bloom/components/entries_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

class EntriesScreen extends StatefulWidget {
  const EntriesScreen({super.key});

  @override
  State<EntriesScreen> createState() => _EntriesScreenState();
}

class _EntriesScreenState extends State<EntriesScreen> {
  // Required variables
  final user = FirebaseAuth.instance.currentUser;
  final searchController = TextEditingController();
  final searchFocusNode = FocusNode();
  bool toggleDayView = false;
  bool toggleSearch = false;
  int? numberOfBooks = 0;
  int? numberOfEntries = 0;
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
    // Format intial date and time to strings
    setState(() {
      date = DateFormat('dd-MM-yyyy').format(now);
      time = DateFormat('h:mm a').format(now);
    });
    fetchAccountData();
    // initBannerAd();
    migrateLowercaseFields('entries');
    migrateLowercaseFields('books');
  }

  /// Fetch accountData
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

  /// Migrate the Title's of old Entries to support
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
        'entries': 'mainEntryTitle',
        'books': 'bookTitle',
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

  /// Banner ADs initialization method
  void initBannerAd() {
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

  /// Search the [FirebaseFirestore] for the user's query.
  /// [query] a [String] that is the user's search query.
  Future<void> searchFirestore(String query) async {
    if (query.isEmpty) {
      setState(() => searchResults = []);
      return;
    }

    final normalized = query.toLowerCase();

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('entries')
        .where('mainEntryTitle_lower', isGreaterThanOrEqualTo: normalized)
        .where('mainEntryTitle_lower', isLessThanOrEqualTo: '$normalized\uf8ff')
        .get();

    // Fallback: if no results found, try legacy field
    if (snapshot.docs.isEmpty) {
      final legacySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('entries')
          .where('mainEntryTitle', isGreaterThanOrEqualTo: query)
          .where('mainEntryTitle', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      setState(() => searchResults = legacySnapshot.docs);
    } else {
      setState(() => searchResults = snapshot.docs);
    }
  }

  /// Method to retrieve the books
  Stream<List<Map<String, dynamic>>> fetchBooks() {
    Stream<QuerySnapshot<Map<String, dynamic>>> query;
    if (sortValue == 'Recents') {
      query = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('books')
          .orderBy('addedOn', descending: true)
          .snapshots();
    } else if (sortValue == 'Oldest') {
      query = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('books')
          .orderBy('addedOn', descending: false)
          .snapshots();
    } else {
      query = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('books')
          .orderBy('addedOn', descending: true)
          .snapshots();
    }

    return query.map((querySnapshot) {
      numberOfBooks = querySnapshot.docs.length;
      return querySnapshot.docs
          .map((doc) => doc.data()..['bookId'] = doc.id)
          .toList();
    });
  }

  /// Method to retrieve the documents of entries collection to display them
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

  /// Function to convert Quill Delta to RichText
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

  // State update method
  void stateUpdate() {
    setState(() {});
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
        title: const Text('Entries'),
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
              icon: const Icon(Icons.search_rounded)),
        ],
        bottom: toggleSearch
            ? PreferredSize(
                preferredSize: Size(MediaQuery.of(context).size.width, 70),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 8.0,
                    right: 8.0,
                  ),
                  child: SearchBar(
                    controller: searchController,
                    focusNode: searchFocusNode,
                    autoFocus: true,
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(16))),
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
                              searchFocusNode.unfocus();
                              searchController.clear();
                            },
                            icon: const Icon(Icons.close_rounded))
                    ],
                    hintText: 'Search entries',
                    elevation: const WidgetStatePropertyAll(0),
                  ),
                ))
            : null,
      ),
      body: toggleSearch
          ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // padding: EdgeInsets.only(left: 14.0, right: 14.0),
                  searchResults.isEmpty && searchController.text.isEmpty
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: Center(
                              child: Padding(
                            padding: EdgeInsets.only(left: 14.0, right: 14.0),
                            child: Text(
                              'Enter the title of an entry to search for it',
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          )),
                        )
                      : searchResults.isEmpty
                          ? SizedBox(
                              height: MediaQuery.of(context).size.height * 0.8,
                              width: double.maxFinite,
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
                                    ),
                                  ],
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
                  // TODO: DISPLAY THE BOOKS HERE FOR SEARCH RESULTS
                  if (searchResults.isNotEmpty)
                    SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: ListView.builder(
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot doc = searchResults[index];
                            String entryDescription =
                                doc['mainEntryDescription'];
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
                              return EntriesTile(
                                innerPadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
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
                              );
                            }
                          }),
                    ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Default sorting button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: Row(
                      spacing: 8,
                      children: [
                        RawChip(
                          backgroundColor: sortValue != 'Recents'
                              ? Theme.of(context).colorScheme.surfaceContainer
                              : Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                          side: BorderSide.none,
                          labelStyle: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer),
                          iconTheme: IconThemeData(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer),
                          onPressed: () {
                            setState(() {
                              sortValue = 'Recents';
                            });
                          },
                          avatar: Icon(sortValue != 'Recents'
                              ? Icons.filter_alt_rounded
                              : Icons.check_rounded),
                          label: Text('Default'),
                        ),
                        // Custom filters button
                        RawChip(
                          backgroundColor: sortValue != 'Recents'
                              ? Theme.of(context).colorScheme.secondaryContainer
                              : Theme.of(context).colorScheme.surfaceContainer,
                          side: BorderSide.none,
                          labelStyle: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer),
                          iconTheme: IconThemeData(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer),
                          onPressed: () {
                            // Functionality to show the filter and other options as a modal bottom sheet
                            showAdaptiveDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog.adaptive(
                                    backgroundColor: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    title: const Text('Filters'),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 0, vertical: 8),
                                    content: StatefulBuilder(builder:
                                        (BuildContext context,
                                            StateSetter setState) {
                                      return SingleChildScrollView(
                                        child: SizedBox(
                                          height: 260,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Recent button
                                              ListTile(
                                                dense: true,
                                                minVerticalPadding: 0,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 4),
                                                leading: Radio.adaptive(
                                                    value: 'Recents',
                                                    groupValue: sortValue,
                                                    onChanged:
                                                        (String? sortvalue) {
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
                                                    'Sort the entries from recent to oldest'),
                                                subtitleTextStyle: TextStyle(
                                                    color: Colors.grey),
                                                onTap: () {
                                                  setState(() {
                                                    sortValue = 'Recents';
                                                  });
                                                  stateUpdate();
                                                },
                                              ),
                                              // Oldest button
                                              ListTile(
                                                dense: true,
                                                minVerticalPadding: 0,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 4),
                                                leading: Radio.adaptive(
                                                    value: 'Oldest',
                                                    groupValue: sortValue,
                                                    onChanged:
                                                        (String? sortvalue) {
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
                                                    'Sort the entries from oldest to recent'),
                                                subtitleTextStyle: TextStyle(
                                                    color: Colors.grey),
                                                onTap: () {
                                                  setState(() {
                                                    sortValue = 'Oldest';
                                                  });
                                                  stateUpdate();
                                                },
                                              ),
                                              // Favorites button
                                              ListTile(
                                                dense: true,
                                                minVerticalPadding: 0,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 4),
                                                leading: Radio.adaptive(
                                                    value: 'Favorite',
                                                    groupValue: sortValue,
                                                    onChanged:
                                                        (String? sortvalue) {
                                                      setState(() {
                                                        sortValue = sortvalue!;
                                                      });
                                                      stateUpdate();
                                                    }),
                                                horizontalTitleGap: 0,
                                                title: Text(
                                                  'Favorite',
                                                  textAlign: TextAlign.start,
                                                ),
                                                subtitle: Text(
                                                    'Show only favorite entries'),
                                                subtitleTextStyle: TextStyle(
                                                    color: Colors.grey),
                                                onTap: () {
                                                  setState(() {
                                                    sortValue = 'Favorite';
                                                  });
                                                  stateUpdate();
                                                },
                                              ),
                                              // Locked button
                                              ListTile(
                                                dense: true,
                                                minVerticalPadding: 0,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 4),
                                                leading: Radio.adaptive(
                                                    value: 'Locked',
                                                    groupValue: sortValue,
                                                    onChanged:
                                                        (String? sortvalue) {
                                                      setState(() {
                                                        sortValue = sortvalue!;
                                                      });
                                                      stateUpdate();
                                                    }),
                                                horizontalTitleGap: 0,
                                                title: Text(
                                                  'Locked',
                                                  textAlign: TextAlign.start,
                                                ),
                                                subtitle: Text(
                                                    'Show only locked entries'),
                                                subtitleTextStyle: TextStyle(
                                                    color: Colors.grey),
                                                onTap: () {
                                                  setState(() {
                                                    sortValue = 'Locked';
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
                          avatar: Icon(sortValue != 'Recents'
                              ? Icons.check_rounded
                              : Icons.filter_list_rounded),
                          label: Text('Filter'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  if (numberOfBooks != 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'Books',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  const SizedBox(
                    height: 6,
                  ),
                  StreamBuilder(
                      stream: fetchBooks(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 14.0),
                            child: const Skeletonizer(
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
                            )
                                .animate()
                                .fade(delay: const Duration(milliseconds: 50)),
                          );
                        }
                        if (snapshot.hasData && snapshot.data!.isEmpty) {
                          return const SizedBox();
                        }
                        if (snapshot.hasError) {
                          return const Center(
                            child:
                                Text('Error occurred while fetching books...'),
                          );
                        } else {
                          final books = snapshot.data!;
                          return Container(
                            height: 140,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                final bool hasChildren = book['hasChildren'];
                                final bool isBookLocked =
                                    book['isBookLocked'] ?? false;
                                return SizedBox(
                                  width: 120,
                                  child: BookCard(
                                    type: type,
                                    isTemplate: false,
                                    hasChildren: hasChildren,
                                    dateTime: addedOn,
                                    bookId: bookId,
                                    emoji: bookIcon,
                                    title: bookTitle,
                                    description: bookDescription,
                                    isBookLocked: isBookLocked,
                                  ),
                                );
                              },
                            ),
                          );
                        }
                      }),
                  if (numberOfBooks != 0)
                    SizedBox(
                      height: 16,
                    ),
                  if (numberOfEntries != 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'Notes',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  const SizedBox(
                    height: 6,
                  ),
                  StreamBuilder<List<Map<String, dynamic>>>(
                      stream: fetchEntries(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Skeletonizer(
                            enabled: true,
                            containersColor:
                                Theme.of(context).primaryColorLight,
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
                          )
                              .animate()
                              .fade(delay: const Duration(milliseconds: 50));
                        }
                        if (numberOfBooks == 0 && numberOfEntries == 0) {
                          return const SizedBox(
                            child: Padding(
                              padding: EdgeInsets.only(left: 14.0, right: 14.0),
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
                            child:
                                Text('Error occurred while getting entries...'),
                          );
                        } else {
                          final entries = snapshot.data!;
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: entries.length,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final entry = entries[index];
                              final entryDescription =
                                  entry['mainEntryDescription'];
                              final entryTitle = entry['mainEntryTitle'] ?? '';
                              final entryBackgroundImageUrl =
                                  entry['backgroundImageUrl'] ?? '';
                              final entryId = entry['mainEntryId'] ?? '';
                              final entryType = entry['mainEntryType'] ?? '';
                              final entryEmoji = entry['mainEntryEmoji'] ?? '';
                              final entryAttachments =
                                  entry['attachments'] ?? [];
                              final entryChildren = entry['children'];
                              final entryHasChildren = entry['hasChildren'];
                              final Timestamp timestamp = entry['addedOn'];
                              final Timestamp datetime = entry['dateTime'];
                              final DateTime entryDate = timestamp.toDate();
                              final DateTime dateTime = datetime.toDate();
                              final DateTime addedOn = entryDate;
                              final date =
                                  DateFormat('dd-MM-yyyy').format(entryDate);
                              final entryTime =
                                  entry['dateTime']?.toDate() ?? '';
                              final entryIsFavorite = entry['isFavorite'];
                              final time =
                                  DateFormat('h:mm a').format(entryTime);
                              final isSynced = entry['synced'];
                              final isEntryLocked =
                                  entry['isEntryLocked'] ?? false;
                              return EntriesTile(
                                innerPadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
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
                                isTemplate: false,
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     showModalBottomSheet(
      //       context: context,
      //       showDragHandle: true,
      //       enableDrag: true,
      //       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      //       builder: (context) {
      //         return SafeArea(
      //           child: Column(
      //             children: [
      //               // Display all the basic objects
      //               const Expanded(
      //                 child: TypesOfEntries(),
      //               ),
      //               // Display a button to more templates
      //               Row(
      //                 mainAxisAlignment: MainAxisAlignment.center,
      //                 children: [
      //                   const Text(
      //                     'More entry ',
      //                   ),
      //                   InkWell(
      //                     onTap: () {
      //                       if (subscriptionPlan == 'free') {
      //                         showDialog(
      //                             context: context,
      //                             builder: (context) {
      //                               return AlertDialog(
      //                                 backgroundColor: Theme.of(context)
      //                                     .scaffoldBackgroundColor,
      //                                 icon: Icon(
      //                                   Icons.payment_rounded,
      //                                 ),
      //                                 iconColor: Theme.of(context)
      //                                     .textTheme
      //                                     .bodyMedium
      //                                     ?.color,
      //                                 title: const Text(
      //                                     'Upgrade to use templates'),
      //                                 titleTextStyle: TextStyle(
      //                                   fontSize: 24,
      //                                   fontWeight: FontWeight.w400,
      //                                   color: Theme.of(context)
      //                                       .textTheme
      //                                       .bodyMedium
      //                                       ?.color,
      //                                 ),
      //                                 content: const Text(
      //                                   'To use custom templates, you need to be on either the Pro or the Lifetime subscription plans',
      //                                 ),
      //                                 contentTextStyle: TextStyle(
      //                                     fontSize: 14,
      //                                     fontWeight: FontWeight.w400),
      //                                 actions: [
      //                                   // Button to cancel and close the dialog box
      //                                   TextButton(
      //                                     onPressed: () =>
      //                                         Navigator.pop(context),
      //                                     style: const ButtonStyle(
      //                                       foregroundColor:
      //                                           WidgetStatePropertyAll(
      //                                               Colors.red),
      //                                     ),
      //                                     child: const Text('Cancel'),
      //                                   ),
      //                                   // Button to redirect to the subscriptions page
      //                                   TextButton(
      //                                     onPressed: () {
      //                                       Navigator.of(context).push(
      //                                           MaterialPageRoute(
      //                                               builder: (context) =>
      //                                                   UpgradeSubscriptionScreen()));
      //                                     },
      //                                     style: ButtonStyle(
      //                                       foregroundColor:
      //                                           WidgetStatePropertyAll(
      //                                               Theme.of(context)
      //                                                   .primaryColor),
      //                                     ),
      //                                     child: const Text('Upgrade'),
      //                                   ),
      //                                 ],
      //                               );
      //                             });
      //                       } else {
      //                         Navigator.of(context).push(MaterialPageRoute(
      //                             builder: (context) =>
      //                                 const CustomTemplatesScreen()));
      //                       }
      //                     },
      //                     child: const Row(
      //                       children: [
      //                         Text(
      //                           'templates',
      //                           style: TextStyle(
      //                               decoration: TextDecoration.underline,
      //                               fontWeight: FontWeight.w700),
      //                         ),
      //                         Icon(
      //                           Icons.open_in_new_rounded,
      //                           size: 14,
      //                         )
      //                       ],
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //               const SizedBox(height: 8)
      //             ],
      //           ),
      //         );
      //       },
      //     );
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

class Entry {
  final String id;

  Entry({required this.id});
}
