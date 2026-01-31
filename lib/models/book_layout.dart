import 'dart:async';
import 'dart:convert';

import 'package:bloom/authentication_screens/authenticate_object.dart';
import 'package:bloom/components/book_card.dart';
import 'package:bloom/components/delete_confirmation_dialog.dart';
import 'package:bloom/components/entries_tile.dart';
import 'package:bloom/components/bloom_buttons.dart';
import 'package:bloom/components/textfield_nobackground.dart';
import 'package:bloom/models/book_entry.dart';
import 'package:bloom/models/note_layout.dart';
import 'package:bloom/responsive/dimensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';

// ignore: must_be_immutable
class BookLayout extends StatefulWidget {
  final String type;
  final String? bookId;
  final List children;
  final bool hasChildren;
  final bool isFavorite;
  final DateTime dateTime;
  final String? emoji;
  final String? title;
  final String? description;
  final bool? isFirstTime;
  final bool isTemplate;
  final bool? isBookLocked;
  BookLayoutMethod bookLayoutMethod;
  BookLayout(
      {super.key,
      required this.type,
      required this.dateTime,
      required this.title,
      this.description,
      this.emoji,
      this.isFirstTime,
      this.bookId,
      required this.bookLayoutMethod,
      required this.children,
      required this.hasChildren,
      required this.isTemplate,
      required this.isFavorite,
      this.isBookLocked});

  @override
  State<BookLayout> createState() => _BookLayoutState();
}

enum BookLayoutMethod { display, edit }

class _BookLayoutState extends State<BookLayout> {
  // Required variables
  bool isEditing = false;
  bool isSynced = false;
  bool isSearchToggled = false;
  final user = FirebaseAuth.instance.currentUser;
  late TextEditingController titleController;
  final searchController = TextEditingController();
  late TextEditingController descriptionController;
  late TextEditingController emojiController;
  Timer? saveTimer;
  String? bookId;
  bool? isLocked;
  late BookLayoutMethod bookLayoutMethod;
  late EmojiNotifier emojiNotifier;
  final titleFocusNode = FocusNode();
  final descriptionFocusNode = FocusNode();
  String? templateChildContent;
  final searchFocusNode = FocusNode();
  bool? isPrivacyPasswordSet;
  late Stream<List<Map<String, dynamic>>> childrenStream;

  // Method to initialize the variables and other methods
  @override
  void initState() {
    super.initState();
    if (widget.bookId == 'default') {
      bookId = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('books')
          .doc()
          .id;
    } else {
      bookId = widget.bookId;
    }
    loadDefaultTemplateChild(widget.type);
    childrenStream = fetchBookChildren();
    privacyPasswordCheck();
    checkSharedPreferencesIfLocked();
    bookLayoutMethod = widget.bookLayoutMethod;
    titleController = TextEditingController(text: widget.title ?? 'Book');
    descriptionController = TextEditingController(
        text: widget.description ??
            'This is a Book entry type. A Book is a group or collection of similar types of note entries with chapters, bookmarking and other features.');
    emojiController = TextEditingController(text: widget.emoji ?? '📓');
    titleController.addListener(onDataChanged);
    descriptionController.addListener(onDataChanged);
    searchController.addListener(onSearchChanged);
  }

  /// Check the Privacy Password status
  void privacyPasswordCheck() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('security')
          .doc('bloomPin')
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final enabled = data?['enabled'];

        setState(() {
          if ((enabled != null && enabled == true)) {
            isPrivacyPasswordSet = true;
          } else {
            isPrivacyPasswordSet = false;
          }
        });
      }
    } catch (e) {
      //
    }
  }

  /// check if the book entry is locked or not in sharedpreferences
  Future<bool> checkSharedPreferencesIfLocked() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLocked = prefs.getBool(widget.bookId!) ?? widget.isBookLocked;
    });
    return isLocked!;
  }

  /// Method to save the layout to firestore automatically after few seconds of opening it
  void scheduleSave() {
    saveTimer?.cancel();
    saveTimer = Timer(const Duration(milliseconds: 1500), saveBookLayout);
  }

  /// Method to check if the details of the entry are changed/being edited
  void onDataChanged() {
    if (mounted) {
      setState(() {
        isEditing = descriptionController.text != widget.description ||
            titleController.text != widget.title;
        isSynced = isEditing;
      });
    }
    scheduleSave();
  }

  /// Method to display pages when searched by user
  void onSearchChanged() {
    setState(() {
      childrenStream = fetchBookChildren();
    });
  }

  /// Saving book layout method
  Future saveBookLayout() async {
    final firestore = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('books');
    await firestore.doc(bookId).set({
      'type': widget.type,
      'bookId': bookId,
      'hasChildren': false,
      'bookTitle': titleController.text.trim(),
      'bookDescription': descriptionController.text.trim(),
      'bookEmoji': widget.emoji,
      'isCustomized': widget.isTemplate,
      'addedOn': DateTime.now(),
    }, SetOptions(merge: true));
    // Set the syncing status to false after syncing
    setState(() {
      isSynced = false;
    });
  }

  /// Method to fetch the children for the book
  Stream<List<Map<String, dynamic>>> fetchBookChildren() {
    Stream<QuerySnapshot<Map<String, dynamic>>> query;
    if (widget.isTemplate == true) {
      query = FirebaseFirestore.instance
          .collection('templates')
          .doc(widget.bookId)
          .collection('objectTypes')
          .snapshots();
      return query.map((querySnapshot) {
        return querySnapshot.docs
            .map((doc) => doc.data()..['objectId'] = doc.id)
            .toList();
      });
    } else {
      if (isSearchToggled) {
        // If user wants to search through the pages of the book
        query = FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection('books')
            .doc(widget.bookId)
            .collection('pages')
            .orderBy('addedOn', descending: true)
            .where('pageTitle', isGreaterThanOrEqualTo: searchController.text)
            .where('pageTitle',
                isLessThanOrEqualTo: '${searchController.text}\uf8ff')
            .snapshots();
        return query.map((querySnapshot) {
          return querySnapshot.docs
              .map((doc) => doc.data()..['pageId'] = doc.id)
              .toList();
        });
      } else {
        query = FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection('books')
            .doc(widget.bookId)
            .collection('pages')
            .orderBy('addedOn', descending: true)
            .snapshots();
        return query.map((querySnapshot) {
          return querySnapshot.docs
              .map((doc) => doc.data()..['pageId'] = doc.id)
              .toList();
        });
      }
    }
  }

  /// Load the default entry child JSON for Templates
  Future loadDefaultTemplateChild(String title) async {
    if (title.toLowerCase() != 'journal') {
      const String journalTemplateUrl =
          'https://raw.githubusercontent.com/stanlysilas/bloom_data/refs/heads/main/templates/default_journal_entry.json';

      try {
        final response = await http.get(Uri.parse(journalTemplateUrl));

        if (response.statusCode == 200) {
          final List<dynamic> jsonData = jsonDecode(response.body);

          // Optional: print to verify structure
          templateChildContent = jsonEncode(jsonData);

          // Convert JSON → Delta → Document
          final Delta delta = Delta.fromJson(jsonData);
          final Document document = Document.fromDelta(delta);

          return document;
        } else {
          throw Exception(
              'Failed to load default template: ${response.statusCode}');
        }
      } catch (e) {
        return null;
      }
    }
  }

  // Method to dispose the variables
  @override
  void dispose() {
    super.dispose();
    titleController.removeListener(onDataChanged);
    emojiController.removeListener(onDataChanged);
    descriptionController.removeListener(onDataChanged);
    searchController.removeListener(onSearchChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                      Theme.of(context).colorScheme.surfaceContainer)),
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.arrow_back, color: Colors.grey)),
          title: Text(titleController.text.trim(),
              style: TextStyle(
                  fontFamily: 'ClashGrotesk', fontWeight: FontWeight.w500)),
          actions: [
            // Sync status of the entry
            // Show only if its not a template displaying
            if (widget.isTemplate == false)
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 2),
                child: isSynced
                    ? Tooltip(
                        triggerMode: TooltipTriggerMode.tap,
                        message: 'Syncing',
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color:
                                Theme.of(context).colorScheme.surfaceContainer,
                          ),
                          child: Container(
                            height: 8,
                            width: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      )
                    : Tooltip(
                        triggerMode: TooltipTriggerMode.tap,
                        message: 'Synced',
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color:
                                Theme.of(context).colorScheme.surfaceContainer,
                          ),
                          child: Container(
                            height: 8,
                            width: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
              ),
            const SizedBox(
              width: 6,
            ),
            if (widget.isFirstTime != null && widget.isFirstTime! == false)
              IconButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                        Theme.of(context).colorScheme.surfaceContainer)),
                onPressed: () {
                  if (widget.bookLayoutMethod == BookLayoutMethod.edit) {
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        showDragHandle: true,
                        useSafeArea: true,
                        constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.6),
                        builder: (context) {
                          return SafeArea(
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 14,
                                ),
                                // Option to lock the 'Book'
                                if (widget.bookId != 'default')
                                  BloomModalListTile(
                                    title: isLocked == true
                                        ? 'Unlock ${widget.title}'
                                        : 'Lock ${widget.title}',
                                    leadingIcon: Icon(
                                        isLocked == true
                                            ? Icons.lock_open_rounded
                                            : Icons.lock_rounded,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer),
                                    onTap: () async {
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      final useBloomPin =
                                          prefs.getBool('useBloomPin') ?? false;
                                      final bool isAuthenticated =
                                          await authenticate(
                                              'Confirm authentication of this object',
                                              context);
                                      try {
                                        // First check if user has [useBloomPin] set to true or false
                                        if (useBloomPin) {
                                          // Authenticate the user with only Bloom Pin service
                                          // TODO: ADD FUNCTIONALITY TO AUTHENTICATE WITH ONLY BLOOM PIN
                                        } else {
                                          // Check if the Book is already locked or unlocked
                                          if (isLocked == true) {
                                            // Unlock the entry is [isAuthenticated] returns true
                                            if (isAuthenticated) {
                                              // Update the local authentication state
                                              setState(() {
                                                isLocked = false;
                                              });
                                              // Update [FirebaseFirestore] with the new state
                                              prefs.setBool(widget.bookId!,
                                                  isLocked ?? false);
                                              await FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(user?.uid)
                                                  .collection('books')
                                                  .doc(widget.bookId!)
                                                  .update({
                                                'isBookLocked': isLocked,
                                              });
                                              // Show confirmation to the user
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      margin:
                                                          const EdgeInsets.all(
                                                              6),
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      showCloseIcon: true,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12)),
                                                      content: Text(
                                                          'Book Unlocked')));
                                              // Close the modal bottom sheet
                                              Navigator.of(context).pop();
                                            } else {
                                              // User did not authenticate or the authentication failed
                                            }
                                          } else {
                                            // The object is not locked, we need to lock it now after authentication
                                            if (isAuthenticated) {
                                              // Change the local state to locked
                                              setState(() {
                                                isLocked = true;
                                              });
                                              // Update [FirebaseFirestore] with the new state
                                              prefs.setBool(widget.bookId!,
                                                  isLocked ?? true);
                                              await FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(user?.uid)
                                                  .collection('books')
                                                  .doc(widget.bookId!)
                                                  .update({
                                                'isBookLocked': isLocked,
                                              });
                                              // Show confirmation to the user
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      margin:
                                                          const EdgeInsets.all(
                                                              6),
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      showCloseIcon: true,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12)),
                                                      content:
                                                          Text('Book Locked')));
                                              // Close the modal bottom sheet
                                              Navigator.of(context).pop();
                                            } else {
                                              // User did not authenticate or the authentication failed
                                            }
                                          }
                                        }
                                      } catch (e) {
                                        print(e.toString());
                                      }
                                    },
                                  ),
                                // Delete entry option shown only if there is entryId
                                if (widget.bookId != 'default')
                                  BloomModalListTile(
                                    leadingDecoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .errorContainer),
                                    leadingIcon: Icon(Icons.delete_rounded,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onErrorContainer),
                                    title: 'Delete ${widget.title}',
                                    titleStyle: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18,
                                        overflow: TextOverflow.ellipsis,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error),
                                    onTap: () {
                                      if (widget.isBookLocked == true) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            margin: const EdgeInsets.all(6),
                                            behavior: SnackBarBehavior.floating,
                                            showCloseIcon: true,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            content: Text(
                                                'Unlock the book to delete it.'),
                                          ),
                                        );
                                      } else {
                                        showAdaptiveDialog(
                                            context: context,
                                            builder: (context) {
                                              return DeleteConfirmationDialog(
                                                  onPressed: () async {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('users')
                                                        .doc(user?.uid)
                                                        .collection('books')
                                                        .doc(widget.bookId)
                                                        .delete();

                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        margin: const EdgeInsets
                                                            .all(6),
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                        showCloseIcon: true,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12)),
                                                        content: Text(
                                                            'Succesfully deleted book'),
                                                      ),
                                                    );
                                                    Navigator.of(context).pop();
                                                  },
                                                  objectName: widget.title ??
                                                      'Untitled');
                                            });
                                      }
                                    },
                                  ),
                              ],
                            ),
                          );
                        });
                  }
                },
                icon: const Icon(Icons.more_horiz_rounded, color: Colors.grey),
                tooltip: 'Show menu',
              ),
          ]),
      body: SingleChildScrollView(
        child: Padding(
          padding: MediaQuery.of(context).size.width < mobileWidth
              ? const EdgeInsets.all(0)
              : const EdgeInsets.symmetric(horizontal: 250),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Title is displayed here
                    Expanded(
                      child: bookLayoutMethod != BookLayoutMethod.display
                          ? MyTextfieldNobackground(
                              controller: titleController,
                              focusNode: titleFocusNode,
                              autoFocus: false,
                              minLines: 1,
                              maxLines: 3,
                              readOnly:
                                  bookLayoutMethod == BookLayoutMethod.display
                                      ? true
                                      : false,
                              hintText: 'Title',
                              style: TextStyle(fontSize: 22),
                            )
                          : Text(
                              titleController.text,
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),
              ),
              // Description of the Book is displayed here
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: bookLayoutMethod != BookLayoutMethod.display
                    ? MyTextfieldNobackground(
                        controller: descriptionController,
                        focusNode: descriptionFocusNode,
                        hintText: 'Short description',
                        autoFocus: false,
                        readOnly: bookLayoutMethod == BookLayoutMethod.display
                            ? true
                            : false)
                    : Text(descriptionController.text,
                        style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(
                height: 14,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Row(
                  children: [
                    // Searching the book pages option
                    !isSearchToggled
                        ? InkWell(
                            onTap: () {
                              // Toggle search status on/off based on the type of book
                              // If its a template then should not be tappable
                              bookLayoutMethod == BookLayoutMethod.display
                                  ? null
                                  : setState(() {
                                      isSearchToggled = !isSearchToggled;
                                    });
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withAlpha(80))),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.search_rounded,
                                    size: 16,
                                  ),
                                  Text(
                                    'Search',
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Expanded(
                            child: MyTextfieldNobackground(
                              controller: searchController,
                              hintText: 'Search pages',
                              focusNode: searchFocusNode,
                              readOnly: false,
                              maxLines: 1,
                              autoFocus: true,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  searchFocusNode.unfocus();
                                  searchController.clear();
                                  setState(() {
                                    isSearchToggled = !isSearchToggled;
                                  });
                                },
                                icon: const Icon(
                                  Icons.close_rounded,
                                ),
                              ),
                            ),
                          ),
                    if (!isSearchToggled) const Spacer(),
                    // TODO: Sorting the Book pages below option

                    // Button to add a new entry into the Book
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () async {
                        if (bookLayoutMethod != BookLayoutMethod.display) {
                          await saveBookLayout();
                          if (widget.type == 'journal') {
                            // print(
                            //     "JournalTemplateChild: $templateChildContent");
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => NoteLayout(
                                  hasChildren: false,
                                  mainId: bookId,
                                  description: templateChildContent,
                                  date: DateFormat('dd-MM-yyyy')
                                      .format(widget.dateTime),
                                  time: DateFormat('h:mm a')
                                      .format(widget.dateTime),
                                  type: widget.type,
                                  mode: NoteMode.create,
                                  dateTime: widget.dateTime,
                                  isEntryLocked: false,
                                  title: 'A New Day',
                                ),
                              ),
                            );
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => NoteLayout(
                                  hasChildren: false,
                                  mainId: bookId,
                                  date: DateFormat('dd-MM-yyyy')
                                      .format(widget.dateTime),
                                  time: DateFormat('h:mm a')
                                      .format(widget.dateTime),
                                  type: widget.type,
                                  mode: NoteMode.create,
                                  dateTime: widget.dateTime,
                                  isEntryLocked: false,
                                  title: '',
                                ),
                              ),
                            );
                          }
                        } else {
                          null;
                        }
                      },
                      child: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 14,
              ),
              // List all the entries of the Book here
              StreamBuilder(
                  stream: childrenStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                            'An error occurred while fetching pages for ${widget.title}'),
                      );
                    }
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
                    if (snapshot.hasData && snapshot.data!.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 14.0, right: 14.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Image(
                              height: 260,
                              width: 260,
                              image: AssetImage(
                                  'assets/images/entriesEmptyBackground.png'),
                            ),
                            Text(
                              'No pages yet',
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              'Click on the + icon to make a new page',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                    // If the user chooses the default book entry instead of any customised ones
                    if (snapshot.hasData &&
                        snapshot.data!.isEmpty &&
                        widget.isFirstTime == true &&
                        widget.bookId == 'default') {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            // Default entries for the book type
                            return BookCard(
                              isTemplate: false,
                              innerPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 4),
                              onTap: () {
                                // Navigate to the tapped entry in the default book type
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => BookEntry(
                                      dateTime: widget.dateTime,
                                      mode: BookMode.display,
                                      mainBookTitle:
                                          widget.title ?? 'Book default title',
                                      mainType: 'book',
                                      mainBookId: 'default',
                                      mainBookHasChildren: true,
                                      mainBookEmoji: '📓',
                                      mainBookDescription:
                                          descriptionController.text,
                                      entryTitle: "Default title's first page",
                                      entryId: 'default',
                                      entryContent: "",
                                      entryEmoji: '📓',
                                    ),
                                  ),
                                );
                              },
                              emoji: '📓',
                              title: "Default title's first page ",
                              description:
                                  'This is the first page of the Book. This is the area for writing anything and everything you want.',
                              dateTime: widget.dateTime,
                              tags: const ['Personal', 'Daily'],
                              isBookLocked: false,
                            );
                          },
                        ),
                      );
                    } else {
                      if (widget.isTemplate == true) {
                        // If the user choosed a customised entry type (template)
                        final entriesList = snapshot.data!;
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: entriesList.length,
                            itemBuilder: (context, index) {
                              final entryData = entriesList[index];
                              final entryId = entryData['objectId'];
                              final entryEmoji = entryData['objectIcon'];
                              final entryTitle = entryData['objectTitle'];
                              final entryContent =
                                  entryData['objectDescription'];
                              return EntriesTile(
                                  innerPadding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  content: entryContent,
                                  emoji: entryEmoji,
                                  date: DateFormat('dd-MM-yyy')
                                      .format(widget.dateTime),
                                  id: entryId,
                                  mainId: widget.bookId,
                                  type: 'book',
                                  isTemplate: widget.isTemplate,
                                  templateType: widget.title!.toLowerCase(),
                                  backgroundImageUrl: '',
                                  attachments: const [],
                                  hasChildren: false,
                                  children: const [],
                                  isFavorite: false,
                                  addedOn: widget.dateTime,
                                  dateTime: widget.dateTime,
                                  title: entryTitle,
                                  isEntryLocked: false);
                            },
                          ),
                        );
                      } else {
                        // If the user choosed a default/existing entry
                        final entriesList = snapshot.data!;
                        return SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: ListView.builder(
                            itemCount: entriesList.length,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final entryData = entriesList[index];
                              final entryId = entryData['pageId'];
                              final entryEmoji = entryData['pageEmoji'];
                              final entryTitle = entryData['pageTitle'];
                              final entryContent = entryData['pageDescription'];
                              final Timestamp timestamp = entryData['addedOn'];
                              final DateTime addedOn = timestamp.toDate();
                              final Timestamp timeStamp = entryData['dateTime'];
                              final DateTime dateTime = timeStamp.toDate();
                              final String entryType = entryData['pageType'];
                              final attachments = entryData['attachments'];
                              final backgroundImageUrl =
                                  entryData['backgroundImageUrl'];
                              final hasChildren = entryData['hasChildren'];
                              final isFavorite = entryData['isFavorite'];
                              final children = entryData['children'];
                              final isEntryLocked = entryData['isEntryLocked'];
                              return EntriesTile(
                                  innerPadding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  content: entryContent,
                                  emoji: entryEmoji,
                                  date: DateFormat('dd-MM-yyy').format(addedOn),
                                  id: entryId,
                                  mainId: widget.bookId,
                                  type: entryType,
                                  backgroundImageUrl: backgroundImageUrl,
                                  attachments: attachments,
                                  hasChildren: hasChildren,
                                  children: children,
                                  isFavorite: isFavorite,
                                  addedOn: addedOn,
                                  dateTime: dateTime,
                                  title: entryTitle,
                                  isTemplate: widget.isTemplate,
                                  isEntryLocked: isEntryLocked ?? false);
                            },
                          ),
                        );
                      }
                    }
                  }),
              // Ratings for the Template
              // if (widget.isTemplate)
              //   Padding(
              //     padding: const EdgeInsets.all(122),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         ...List.generate(5, (index) {
              //           return Icon(Icons.star);
              //         }),
              //       ],
              //     ),
              //   )
            ],
          ),
        ),
      ),
      floatingActionButton: bookLayoutMethod == BookLayoutMethod.display
          ? FloatingActionButton.extended(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              onPressed: () async {
                setState(() {
                  if (bookLayoutMethod == BookLayoutMethod.display) {
                    // User wants to use this template save it to their database and continue to edit mode.
                    bookLayoutMethod = BookLayoutMethod.edit;
                    saveBookLayout();
                  } else {
                    bookLayoutMethod = BookLayoutMethod.display;
                  }
                });
              },
              icon: Icon(Icons.edit_outlined),
              label: Text('Use template'))
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
