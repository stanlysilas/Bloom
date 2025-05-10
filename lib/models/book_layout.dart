import 'dart:async';

import 'package:bloom/components/book_card.dart';
import 'package:bloom/components/entries_tile.dart';
import 'package:bloom/components/mybuttons.dart';
import 'package:bloom/components/textfield_nobackground.dart';
import 'package:bloom/models/book_entry.dart';
import 'package:bloom/models/note_layout.dart';
import 'package:bloom/responsive/dimensions.dart';
// import 'package:bloom/screens/entries_icon_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
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
      required this.isFavorite});

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
  late BookLayoutMethod bookLayoutMethod;
  late EmojiNotifier emojiNotifier;
  final titleFocusNode = FocusNode();
  final descriptionFocusNode = FocusNode();
  String templateChildContent = '';
  final searchFocusNode = FocusNode();

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
    loadDefaultTemplateChild();
    bookLayoutMethod = widget.bookLayoutMethod;
    titleController = TextEditingController(text: widget.title ?? 'Book');
    descriptionController = TextEditingController(
        text: widget.description ??
            'This is a Book entry type. A Book is a group or collection of similar types of note entries with chapters, bookmarking and other features.');
    emojiController = TextEditingController(text: widget.emoji ?? '📓');
    titleController.addListener(onDataChanged);
    descriptionController.addListener(onDataChanged);
    searchController.addListener(onSearchChanged);
    // emojiController.addListener(onDataChanged);
    // Listen to emoji changes and initialize the emoji
    // emojiNotifier = Provider.of<EmojiNotifier>(context, listen: false);
    // emojiNotifier.addListener(onEmojiChanged);
    // emojiNotifier.addListener(onDataChanged);
    // emojiController.text = emojiNotifier.emoji.toString();
  }

  // Method to save the layout to firestore automatically after few seconds of opening it
  void scheduleSave() {
    saveTimer?.cancel();
    saveTimer = Timer(const Duration(milliseconds: 1500), saveBookLayout);
  }

  // Method to check if the details of the entry are changed/being edited
  void onDataChanged() {
    if (mounted) {
      setState(() {
        isEditing = descriptionController.text != widget.description ||
            // emojiController.text.trim() != widget.emoji ||
            // emojiNotifier.emoji.toString() != emojiController.text.trim() ||
            titleController.text != widget.title;
        isSynced = isEditing;
      });
    }
    scheduleSave();
  }

  // Method to display pages when searched by user
  void onSearchChanged() {
    setState(() {});
  }

  // Method to save the emoji if it changes
  // void onEmojiChanged() {
  //   if (mounted) {
  //     setState(() {
  //       emojiController.text =
  //           Provider.of<EmojiNotifier>(context, listen: false).emoji!;
  //     });
  //   }
  //   scheduleSave();
  // }

  // Saving book layout method
  Future saveBookLayout() async {
    final firestore = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('books');
    await firestore.doc(bookId).set({
      'type': widget.type,
      'bookId': bookId,
      'hasChildren': false,
      'bookTitle': widget.title,
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

  // Method to fetch the children for the book
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

  // Load the default entry child JSON for Templates
  loadDefaultTemplateChild() async {
    if (widget.title!.toLowerCase() == 'journal') {
      templateChildContent = await DefaultAssetBundle.of(context)
          .loadString('lib/required_data/defaultjournalentry.json');
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
    // emojiNotifier.removeListener(onEmojiChanged);
    // emojiNotifier.removeListener(onDataChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            titleController.text.trim(),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          actions: [
            // Sync status of the entry
            // Show only if its not a template displaying
            if (widget.isTemplate == false)
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 2),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Theme.of(context).primaryColorLight,
                  ),
                  child: isSynced
                      ? Tooltip(
                          message: 'Syncing',
                          child: Container(
                            height: 8,
                            width: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.blue,
                            ),
                          ),
                        )
                      : Tooltip(
                          message: 'Synced',
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
            IconButton(
              onPressed: () {
                if (widget.bookLayoutMethod == BookLayoutMethod.edit) {
                  showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      showDragHandle: true,
                      useSafeArea: true,
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width,
                        minHeight: MediaQuery.of(context).size.height / 2,
                      ),
                      builder: (context) {
                        return Container(
                          padding: const EdgeInsets.all(8),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 14,
                              ),
                              // Delete entry option shown only if there is entryId
                              if (widget.bookId != 'default')
                                ExtraOptionsButton(
                                  icon: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color:
                                            Theme.of(context).primaryColorLight,
                                      ),
                                      child: const Icon(
                                        Iconsax.trash,
                                        color: Colors.red,
                                      )),
                                  label: 'Delete entry',
                                  iconLabelSpace: 8,
                                  labelStyle: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.red),
                                  innerPadding: const EdgeInsets.all(12),
                                  onTap: () async {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(user?.uid)
                                        .collection('books')
                                        .doc(widget.bookId)
                                        .delete();

                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        margin: const EdgeInsets.all(6),
                                        behavior: SnackBarBehavior.floating,
                                        showCloseIcon: true,
                                        closeIconColor: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        content: Text(
                                          'Succesfully deleted book',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color),
                                        ),
                                      ),
                                    );
                                  },
                                  endIcon: const Icon(
                                    Iconsax.arrow_right,
                                    color: Colors.red,
                                  ),
                                ),
                            ],
                          ),
                        );
                      });
                }
              },
              icon: const Icon(Iconsax.more),
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
                    // // Emoji is displayed here
                    // emojiController.text.isEmpty
                    //     ? InkWell(
                    //         onTap: () => Navigator.of(context).push(
                    //             MaterialPageRoute(
                    //                 builder: (context) => EntriesIconPicker(
                    //                     icon: emojiController.text.trim(),
                    //                     iconNotifier: emojiNotifier))),
                    //         borderRadius: BorderRadius.circular(5),
                    //         child: Container(
                    //             padding: const EdgeInsets.all(2),
                    //             decoration: BoxDecoration(
                    //               color: Theme.of(context).primaryColorLight,
                    //               borderRadius: BorderRadius.circular(5),
                    //             ),
                    //             child: const Text(
                    //               'Add icon',
                    //               style:
                    //                   TextStyle(fontSize: 12, color: Colors.grey),
                    //             )),
                    //       )
                    //     : InkWell(
                    //         onTap: () => Navigator.of(context).push(
                    //             MaterialPageRoute(
                    //                 builder: (context) => EntriesIconPicker(
                    //                     icon: emojiController.text.trim(),
                    //                     iconNotifier: emojiNotifier))),
                    //         borderRadius: BorderRadius.circular(5),
                    //         child: Container(
                    //           padding: const EdgeInsets.all(2),
                    //           decoration: BoxDecoration(
                    //             color: Theme.of(context).primaryColorLight,
                    //             borderRadius: BorderRadius.circular(5),
                    //           ),
                    //           child: Text(
                    //             emojiNotifier.emoji.toString(),
                    //             style: const TextStyle(fontSize: 25),
                    //           ),
                    //         ),
                    //       ),
                    // const SizedBox(
                    //   width: 6,
                    // ),
                    // Title is displayed here
                    Expanded(
                      child: bookLayoutMethod != BookLayoutMethod.display
                          ? MyTextfieldNobackground(
                              controller: titleController,
                              focusNode: titleFocusNode,
                              readOnly:
                                  bookLayoutMethod == BookLayoutMethod.display
                                      ? true
                                      : false,
                              hintText: 'Title',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color),
                            )
                          : Text(
                              titleController.text,
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color),
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
                        readOnly: bookLayoutMethod == BookLayoutMethod.display
                            ? true
                            : false,
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color),
                      )
                    : Text(
                        descriptionController.text,
                        style: TextStyle(
                            fontSize: 16,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color),
                      ),
              ),
              const SizedBox(
                height: 8,
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
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .primaryColorDark
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
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                              ),
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
                              suffixIconColor:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                    if (!isSearchToggled) const Spacer(),
                    // Sorting the Book pages below option

                    // Button to add a new entry into the Book
                    InkWell(
                      onTap: () async {
                        if (bookLayoutMethod != BookLayoutMethod.display) {
                          await saveBookLayout();
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
                        } else {
                          null;
                        }
                      },
                      child: const Icon(Iconsax.add),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.0),
                child: Divider(),
              ),
              // List all the entries of the Book here
              StreamBuilder(
                  stream: fetchBookChildren(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Error...'),
                      );
                    }
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
                          subtitle: Text(
                            'So this is the text of the subtitle of the object here...',
                            maxLines: 1,
                          ),
                          trailing: Text('End'),
                        ),
                      ).animate().fade(delay: const Duration(milliseconds: 50));
                    }
                    if (snapshot.hasData && snapshot.data!.isEmpty) {
                      return SizedBox(
                        child: Padding(
                          padding:
                              const EdgeInsets.only(left: 14.0, right: 14.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Image(
                                image: AssetImage(
                                    'assets/images/entriesEmptyBackground.png'),
                              ),
                              Text(
                                'Make a new ${titleController.text} entry',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                'Click on the + icon to make a new page in your ${titleController.text}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
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
                            return Column(
                              children: [
                                BookCard(
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
                                          mainBookTitle: widget.title ??
                                              'Book default title',
                                          mainType: 'book',
                                          mainBookId: 'default',
                                          mainBookHasChildren: true,
                                          mainBookEmoji: '📓',
                                          mainBookDescription:
                                              descriptionController.text,
                                          entryTitle:
                                              "Default title's first page",
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
                                ),
                                const Divider(),
                              ],
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
                              return Column(
                                children: [
                                  EntriesTile(
                                      innerPadding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 4),
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
                                      isEntryLocked: false),
                                  // BookTile(
                                  //   innerPadding: const EdgeInsets.symmetric(
                                  //       horizontal: 14, vertical: 4),
                                  //   onTap: () {
                                  //     bookLayoutMethod == BookLayoutMethod.display
                                  //         ? null
                                  //         : Navigator.of(context).push(
                                  //             MaterialPageRoute(
                                  //               builder: (context) => BookEntry(
                                  //                 dateTime: widget.dateTime,
                                  //                 mode: BookMode.create,
                                  //                 mainBookTitle: entryTitle,
                                  //                 mainBookHasChildren: true,
                                  //                 mainBookEmoji: '📓',
                                  //                 entryId: entryId,
                                  //                 mainType: 'book',
                                  //                 entryTitle: 'My Journal',
                                  //                 entryContent: entryContent,
                                  //               ),
                                  //             ),
                                  //           );
                                  //   },
                                  //   emoji: entryEmoji,
                                  //   title: entryTitle,
                                  //   content:
                                  //       'This is the first page of the Book. This is the area for writing anything and everything you want.',
                                  //   dateTime: widget.dateTime,
                                  //   tags: const ['Personal', 'Daily'],
                                  // ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14.0),
                                    child: const Divider().animate().fade(
                                        delay:
                                            const Duration(milliseconds: 250)),
                                  )
                                ],
                              );
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
                              return Column(
                                children: [
                                  EntriesTile(
                                      innerPadding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 4),
                                      content: entryContent,
                                      emoji: entryEmoji,
                                      date: DateFormat('dd-MM-yyy')
                                          .format(addedOn),
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
                                      isEntryLocked: isEntryLocked ?? false),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14.0),
                                    child: const Divider().animate().fade(
                                        delay:
                                            const Duration(milliseconds: 250)),
                                  )
                                ],
                              );
                            },
                          ),
                        );
                      }
                    }
                  })
            ],
          ),
        ),
      ),
      floatingActionButton: bookLayoutMethod == BookLayoutMethod.display
          ? InkWell(
              borderRadius: BorderRadius.circular(100),
              onTap: () async {
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
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Theme.of(context).primaryColor),
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Use template',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
