// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloom/components/custom_textediting_toolbar.dart';
import 'package:bloom/components/more_entry_options.dart';
import 'package:bloom/components/textfield_nobackground.dart';
import 'package:bloom/responsive/dimensions.dart';
import 'package:bloom/screens/entries_background_images.dart';
import 'package:bloom/screens/entries_icon_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteLayout extends StatefulWidget {
  final bool hasChildren;
  final bool? isFavorite;
  final String? title;
  final String? description;
  final String? noteId;
  final String? date;
  final String time;
  final String? emoji;
  final List? childNotes;
  late String? backgroundImageUrl;
  final List? attachments;
  final String type;
  final NoteMode mode;
  final bool? isSynced;
  final bool isEntryLocked;
  final DateTime dateTime;
  final String? mainId;
  final bool? isTemplate;
  final String? templateType;
  NoteLayout({
    super.key,
    required this.hasChildren,
    this.description,
    this.noteId,
    this.attachments,
    required this.date,
    required this.time,
    this.emoji,
    this.childNotes,
    this.backgroundImageUrl,
    required this.type,
    required this.mode,
    this.isFavorite,
    this.isSynced,
    required this.dateTime,
    this.title,
    required this.isEntryLocked,
    this.mainId,
    this.isTemplate,
    this.templateType,
  });

  @override
  State<NoteLayout> createState() => _NoteLayoutState();
}

// Enum to represent different modes
enum NoteMode { create, display, edit }

class _NoteLayoutState extends State<NoteLayout> {
  // Required variables
  bool isEditing = false;
  bool isSynced = false;
  bool? isTitle;
  bool isDarkTheme = false;
  bool hasChildren = false;
  late bool? isFavorite;
  final userId = FirebaseAuth.instance.currentUser?.uid;
  String backgroundImageUrl = '';
  String? type;
  String emoji = '';
  DateTime? addedOn;
  late String documentId;
  final List childNotes = [];
  final List attachments = [];
  List<String> docIds = [];
  List<String> backgroundImageUrlsList = [
    'assets/background_images/obsidian_essence.jpg',
    'assets/background_images/cozy_autumn_rain.gif',
    'assets/background_images/foggy_peak_1.jpg',
    'assets/background_images/foggy_peak_2.jpg',
    'assets/background_images/mountain_peak_dark.jpg',
    'assets/background_images/roman_pillars.jpg',
    'assets/background_images/sand_dunes.jpg',
    'assets/background_images/sunset_in_the_mountains.jpg',
    'assets/background_images/white_globe.jpg',
  ];
  List<String> backgroundImageUrlsNamesList = [
    'Obsidian Essence',
    'Cozy Autumn Rain',
    'Foggy Peak 1',
    'Foggy Peak 2',
    'Mountain Peak - Dark',
    'Roman Pillars',
    'Sand Dunes',
    'Sunset in the Mountains',
    'White Globe',
  ];
  late TextEditingController searchEmojisController;
  late TextEditingController titleController;
  late QuillController descriptionController;
  final titleFocusNode = FocusNode();
  Timer? _saveTimer;
  final GlobalKey _scaffold = GlobalKey();
  late BackgroundImageNotifier backgroundImageNotifier;
  late EmojiNotifier emojiNotifier;
//   CharacterShortcutEvent openToolbar = CharacterShortcutEvent(
//     key: 'Show the toolbar for desktop when / is typed',
//     character: '/',
//     handler: (controller) {
//       return true;
//     },
//   );

  // Method to initialise the required variables and methods
  @override
  void initState() {
    super.initState();
    searchEmojisController = TextEditingController(text: widget.emoji ?? '');
    titleController = TextEditingController(text: widget.title);
    isFavorite = widget.isFavorite ?? false;
    if (widget.mode == NoteMode.create) {
    } else {}

    final description = getDocumentFromDescription(widget.description);

    descriptionController = QuillController(
      document: description,
      selection: const TextSelection.collapsed(offset: 0),
    );

    // Add listeners to the QuillController and titleController
    descriptionController.addListener(onDataChanged);
    titleController.addListener(onDataChanged);
    type = widget.type;
    // Initialize the document ID
    documentId = widget.noteId ??
        FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('entries')
            .doc()
            .id;

    // Listen to background image changes and initialize the image
    backgroundImageNotifier =
        Provider.of<BackgroundImageNotifier>(context, listen: false);
    backgroundImageNotifier.addListener(onBackgroundImageChanged);
    backgroundImageNotifier.addListener(onDataChanged);
    backgroundImageUrl = widget.backgroundImageUrl ?? '';
    backgroundImageNotifier._backgroundImageUrl =
        widget.backgroundImageUrl ?? '';

    // Listen to emoji changes and initialize the emoji
    emojiNotifier = Provider.of<EmojiNotifier>(context, listen: false);
    emojiNotifier.addListener(onEmojiChanged);
    emojiNotifier.addListener(onDataChanged);
    emoji = widget.emoji ?? '';
    emojiNotifier._emoji = widget.emoji ?? '';

    // Check if dark theme is enabled
    isDarkThemeEnabled();
  }

  // Method to dispose off the initialised variables and others
  @override
  void dispose() {
    searchEmojisController.dispose();
    descriptionController.dispose();
    titleController.dispose();
    backgroundImageNotifier.removeListener(onBackgroundImageChanged);
    backgroundImageNotifier.removeListener(onDataChanged);
    emojiNotifier.removeListener(onEmojiChanged);
    emojiNotifier.removeListener(onDataChanged);
    titleController.removeListener(onDataChanged);
    super.dispose();
  }

  // Method to convert the description to a Document
  Document getDocumentFromDescription(String? description) {
    if (description == null || description.isEmpty) {
      return Document();
    }

    try {
      var delta = Delta.fromJson(jsonDecode(description));
      return Document.fromDelta(delta);
    } catch (e) {
      return Document();
    }
  }

  // Method to check if the details of the entry are changed/being edited
  void onDataChanged() {
    if (mounted) {
      setState(() {
        isEditing =
            jsonEncode(descriptionController.document.toDelta().toJson()) !=
                    widget.description ||
                backgroundImageUrl != widget.backgroundImageUrl ||
                emoji != widget.emoji ||
                titleController.text != widget.title;
        isSynced = isEditing;
      });
    }
    scheduleSave();
  }

// Method to save the backgroundImage if it changes
  void onBackgroundImageChanged() {
    if (mounted) {
      setState(() {
        backgroundImageUrl =
            Provider.of<BackgroundImageNotifier>(context, listen: false)
                .backgroundImageUrl!;
      });
    }
    scheduleSave();
  }

  // Method to save the emoji if it changes
  void onEmojiChanged() {
    if (mounted) {
      setState(() {
        emoji = Provider.of<EmojiNotifier>(context, listen: false).emoji!;
      });
    }
    scheduleSave();
  }

  // Schedule save with a delay to avoid excessive writes
  void scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 1500), saveNoteData);
  }

  // Method to save all the data of the note into the database
  Future saveNoteData() async {
    if (widget.type == 'note') {
      final firestore = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('entries');
      var description =
          jsonEncode(descriptionController.document.toDelta().toJson());
      if (descriptionController.document.isEmpty() == false ||
          backgroundImageUrl.isNotEmpty ||
          titleController.text.isNotEmpty ||
          emoji.isNotEmpty) {
        await firestore.doc(documentId).set({
          'mainEntryId': documentId,
          'mainEntryTitle': titleController.text,
          'mainEntryDescription': description,
          'addedOn': DateTime.now(),
          'dateTime': Timestamp.now(),
          'hasChildren': hasChildren,
          'mainEntryEmoji': emoji,
          'mainEntryType': type,
          'backgroundImageUrl': backgroundImageUrl,
          'children': childNotes,
          'attachments': attachments,
          'synced': isEditing,
          'isFavorite': isFavorite,
        }, SetOptions(merge: true));
        // Set the syncing status to false after syncing
        setState(() {
          isSynced = false;
        });
      }
    } else if (widget.type == 'book') {
      print("Main ID of Book: ${widget.mainId}");
      final firestore = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('books')
          .doc(widget.mainId)
          .collection('pages');
      var description =
          jsonEncode(descriptionController.document.toDelta().toJson());
      if (descriptionController.document.isEmpty() == false ||
          backgroundImageUrl.isNotEmpty ||
          titleController.text.isNotEmpty ||
          emoji.isNotEmpty) {
        await firestore.doc(documentId).set({
          'bookId': widget.mainId,
          'pageId': documentId,
          'pageTitle': titleController.text,
          'pageDescription': description,
          'addedOn': DateTime.now(),
          'dateTime': Timestamp.now(),
          'hasChildren': hasChildren,
          'pageEmoji': emoji,
          'pageType': type,
          'backgroundImageUrl': backgroundImageUrl,
          'children': childNotes,
          'attachments': attachments,
          'synced': isEditing,
          'isFavorite': isFavorite,
        }, SetOptions(merge: true));
        // Set the syncing status to false after syncing
        setState(() {
          isSynced = false;
        });
      }
    }
  }

  int wordNum = 0;
  void countWords() {
    int wordscount = descriptionController.document.toPlainText().length +
        titleController.text.length;
    setState(() {
      wordNum = wordscount - 1;
    });
  }

  // Method to check if darkTheme is enabled
  Future<void> isDarkThemeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    });
  }

  @override
  Widget build(BuildContext mainContext) {
    final focusProvider = Provider.of<EditorFocusProvider>(context);
    return SafeArea(
      child: Scaffold(
        key: _scaffold,
        appBar: AppBar(
          backgroundColor:
              Theme.of(context).scaffoldBackgroundColor,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                Provider.of<EmojiNotifier>(context).emoji.toString(),
              ),
              const SizedBox(
                height: 3,
              ),
              Expanded(
                child: Text(
                  widget.title!.isEmpty || widget.title == null
                      ? 'Untitled'
                      : widget.title!,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          actions: [
            // Sync status of the entry
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
            // More options button
            Padding(
              padding: const EdgeInsets.only(top: 2.0, right: 4),
              child: IconButton(
                tooltip: 'Show menu',
                onPressed: () async {
                  countWords();
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
                      return SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: MoreEntryOptions(
                          entryId: widget.noteId ?? '',
                          syncingStatus: isEditing,
                          numberOfWords: wordNum,
                          emoji: emoji,
                          emojiNotifier: emojiNotifier,
                          backgroundImageNotifier: backgroundImageNotifier,
                          isFavorite: isFavorite,
                          onDataChanged: onDataChanged,
                          dateTime: widget.dateTime,
                          isEntryLocked: widget.isEntryLocked,
                          controller: descriptionController,
                          type: type!,
                          mainId: widget.mainId,
                        ),
                      );
                    },
                    showDragHandle: true,
                  );
                },
                icon: const Icon(
                  Iconsax.more,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stack for displaying background image and emoji on top of each other
              // Baackground Image
              Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  Column(
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => EntriesBackgroundImages(
                                backgroundImageNotifier:
                                    backgroundImageNotifier))),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: Provider.of<BackgroundImageNotifier>(context)
                                      .backgroundImageUrl ==
                                  ''
                              ? 100
                              : Platform.isAndroid
                                  ? MediaQuery.of(context).size.height * 0.22
                                  : Platform.isWindows
                                      ? MediaQuery.of(context).size.height * 0.3
                                      : MediaQuery.of(context).size.height * 0.22,
                          child: Provider.of<BackgroundImageNotifier>(context)
                                      .backgroundImageUrl ==
                                  ''
                              ? const SizedBox()
                              : Image.asset(
                                  Provider.of<BackgroundImageNotifier>(context)
                                      .backgroundImageUrl
                                      .toString(),
                                  fit: BoxFit.cover,
                                ).animate().fadeIn(
                                    duration: const Duration(
                                      milliseconds: 500,
                                    ),
                                  ),
                        ),
                      ),
                      SizedBox(
                        height: 36,
                        width: MediaQuery.of(context).size.width,
                      )
                    ],
                  ).animate().fadeIn(duration: const Duration(milliseconds: 500)),
                  // Emoji box
                  Provider.of<EmojiNotifier>(context).emoji == '' ||
                          Provider.of<EmojiNotifier>(context).emoji == null
                      ? const SizedBox()
                      : Padding(
                          padding: MediaQuery.of(context).size.width < mobileWidth
                              ? const EdgeInsets.all(0)
                              : const EdgeInsets.symmetric(horizontal: 250),
                          child: InkWell(
                            onTap: () =>
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => EntriesIconPicker(
                                          icon: emoji,
                                          iconNotifier: emojiNotifier,
                                        ))),
                            // Emoji container
                            child: Container(
                              height: 70,
                              width: 70,
                              alignment: Alignment.bottomCenter,
                              child: Text(
                                Provider.of<EmojiNotifier>(context)
                                    .emoji
                                    .toString(),
                                style: const TextStyle(fontSize: 45),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
              // Display the add icon button if no icon exists
              Padding(
                padding: MediaQuery.of(context).size.width < mobileWidth
                    ? const EdgeInsets.all(0)
                    : const EdgeInsets.symmetric(horizontal: 250),
                child: Row(
                  children: [
                    Provider.of<EmojiNotifier>(context).emoji == '' ||
                            Provider.of<EmojiNotifier>(context).emoji == null
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 2),
                            child: InkWell(
                              onTap: () =>
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => EntriesIconPicker(
                                            icon: emoji,
                                            iconNotifier: emojiNotifier,
                                          ))),
                              child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: Theme.of(context).primaryColorLight,
                                  ),
                                  child: const Text(
                                    'Add icon',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  )),
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
              // Title of the note should be displayed here
              Padding(
                padding: MediaQuery.of(context).size.width < mobileWidth
                    ? const EdgeInsets.symmetric(horizontal: 8)
                    : const EdgeInsets.symmetric(horizontal: 250),
                child: MyTextfieldNobackground(
                  readOnly: false,
                  controller: titleController,
                  focusNode: titleFocusNode,
                  maxLines: 1,
                  hintText: 'Title',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              // Description of the note should be displayed here
              Padding(
                padding: MediaQuery.of(context).size.width < mobileWidth
                    ? const EdgeInsets.all(0)
                    : const EdgeInsets.symmetric(horizontal: 250),
                child: QuillEditor(
                  focusNode: focusProvider.editorFocusNode,
                  scrollController: ScrollController(),
                  configurations: QuillEditorConfigurations(
                    controller: descriptionController,
                    padding: const EdgeInsets.only(left: 8, right: 8, bottom: 10),
                    scrollable: true,
                    scrollBottomInset: 300,
                    requestKeyboardFocusOnCheckListChanged: true,
                    placeholder: 'Start typing here',
                    enableScribble: true,
                    isOnTapOutsideEnabled: true,
                    customStyles: DefaultStyles(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      leading: DefaultListBlockStyle(
                          TextStyle(
                            foreground: Paint()
                              ..color =
                                  Theme.of(context).textTheme.bodyMedium!.color ??
                                      Colors.black,
                          ),
                          const VerticalSpacing(0, 0),
                          const VerticalSpacing(0, 0),
                          null,
                          null),
                      paragraph: DefaultTextBlockStyle(
                        TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                            fontSize: 16,
                            fontFamily: 'Nunito'),
                        const VerticalSpacing(0, 0),
                        const VerticalSpacing(0, 0),
                        const BoxDecoration(),
                      ),
                      bold: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.bold),
                      italic: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontStyle: FontStyle.italic),
                      underline:
                          const TextStyle(decoration: TextDecoration.underline),
                      small: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color),
                      sizeHuge: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 22),
                      sizeLarge: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 18),
                      sizeSmall: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 16),
                      code: DefaultTextBlockStyle(
                        TextStyle(
                            foreground: Paint()
                              ..color =
                                  Theme.of(context).textTheme.bodyMedium!.color ??
                                      Colors.black),
                        const VerticalSpacing(0, 0),
                        const VerticalSpacing(0, 0),
                        BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context).primaryColorLight),
                      ),
                      inlineCode: InlineCodeStyle(
                          radius: const Radius.circular(8),
                          backgroundColor: Colors.transparent,
                          style: TextStyle(
                              background: Paint()
                                ..color = Theme.of(context).primaryColorDark,
                              foreground: Paint()
                                ..color = Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color ??
                                    Colors.black)),
                      quote: DefaultTextBlockStyle(
                          TextStyle(
                            foreground: Paint()
                              ..color =
                                  Theme.of(context).textTheme.bodyMedium!.color ??
                                      Colors.black,
                          ),
                          const VerticalSpacing(0, 0),
                          const VerticalSpacing(0, 0),
                          BoxDecoration(
                              border: Border(
                                  left: BorderSide(
                                      color: Theme.of(context).primaryColorDark,
                                      width: 4)))),
                      lists: DefaultListBlockStyle(
                          TextStyle(
                            foreground: Paint()
                              ..color =
                                  Theme.of(context).textTheme.bodyMedium!.color ??
                                      Colors.black,
                          ),
                          const VerticalSpacing(0, 0),
                          const VerticalSpacing(0, 0),
                          const BoxDecoration(),
                          null),
                    ),
                    onTapOutside: (event, focusNode) {
                      focusNode.unfocus();
                    },
                    onScribbleActivated: () {
                      // Add the functionality for writing with apple pencil and others here
                    },
                    onImagePaste: (imageBytes) async {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              'User pasted an image. Process and display it properly.')));
                      return;
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 100,
              ),
            ],
          ),
        ),
        bottomSheet: isEditing
            ? Row(
                children: [
                  // Text formatting options button
                  Expanded(
                    child: Container(
                      color: Theme.of(context).primaryColorLight,
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: 50,
                      child: CustomHorizontalTextEditingToolbar(
                        controller: descriptionController,
                        focusNode: focusProvider.editorFocusNode,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 28,
                    child: VerticalDivider(
                      width: 2,
                    ),
                  ),
                  isEditing
                      ? InkWell(
                          borderRadius: BorderRadius.circular(5),
                          onTap: () {
                            setState(() {
                              isEditing = false;
                              focusProvider.unfocusEditor();
                              titleFocusNode.unfocus();
                            });
                          },
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            alignment: Alignment.center,
                            color: Theme.of(context).primaryColorLight,
                            child: const Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 2, bottom: 10),
                                  child: Icon(Icons.keyboard),
                                ),
                                SizedBox(),
                                Icon(Icons.keyboard_arrow_down_rounded),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox(),
                ],
              ).animate().fade(
                delay: const Duration(milliseconds: 600), curve: Curves.easeInOut)
            : const SizedBox(),
      ),
    );
  }
}

class BackgroundImageNotifier extends ChangeNotifier {
  String? _backgroundImageUrl;
  bool _isDisposed = false;

  String? get backgroundImageUrl => _backgroundImageUrl;

  set backgroundImageUrl(String? value) {
    if (_isDisposed) {
      // Handle error: Notifier is disposed
      return;
    }

    if (_backgroundImageUrl != value) {
      _backgroundImageUrl = value;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

class EmojiNotifier extends ChangeNotifier {
  String? _emoji;
  bool _isDisposed = false;

  String? get emoji => _emoji;

  set emoji(String? value) {
    if (_isDisposed) {
      // Handle error: Notifier is disposed
      return;
    }

    if (_emoji != value) {
      _emoji = value;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

class EditorFocusProvider extends ChangeNotifier {
  final FocusNode editorFocusNode = FocusNode();
  final FocusNode dummyFocusNode = FocusNode();
  late QuillController controller;

  void unfocusEditor() {
    controller = QuillController(
        document: Document(),
        selection: const TextSelection.collapsed(offset: 0),
        editorFocusNode: editorFocusNode);
    dummyFocusNode.requestFocus();
    controller.editorFocusNode!.unfocus();
    notifyListeners();
  }

  @override
  void dispose() {
    editorFocusNode.dispose();
    dummyFocusNode.dispose();
    super.dispose();
  }
}
