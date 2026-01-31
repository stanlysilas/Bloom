// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:convert';

import 'package:bloom/components/custom_textediting_toolbar.dart';
import 'package:bloom/components/more_entry_options.dart';
import 'package:bloom/components/textfield_nobackground.dart';
import 'package:bloom/models/bloom_ai.dart';
import 'package:bloom/responsive/dimensions.dart';
import 'package:bloom/screens/entries_background_images.dart';
import 'package:bloom/screens/entries_icon_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:provider/provider.dart';

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
  late TextEditingController searchEmojisController;
  late TextEditingController titleController;
  late QuillController descriptionController;
  final titleFocusNode = FocusNode();
  Timer? _saveTimer;
  final GlobalKey _scaffold = GlobalKey();
  late BackgroundImageNotifier backgroundImageNotifier;
  late EmojiNotifier emojiNotifier;
  bool textFormatEnabled = false;
  bool bloomAIEnabled = false;

  // Method to initialise the required variables and methods
  @override
  void initState() {
    super.initState();
    searchEmojisController = TextEditingController(text: widget.emoji ?? '');
    titleController = TextEditingController(text: widget.title);
    isFavorite = widget.isFavorite ?? false;
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

  /// Method to save all the data of the note into the database
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
          'mainEntryTitle_lower': titleController.text.toLowerCase(),
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
          'isEntryLocked': widget.isEntryLocked,
        }, SetOptions(merge: true));
        // Set the syncing status to false after syncing
        setState(() {
          isSynced = false;
        });
      }
    } else if (widget.type == 'book') {
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
          'pageTitle_lower': titleController.text.toLowerCase(),
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

  /// Function to count the words in the Note.
  void countWords() {
    int wordscount = descriptionController.document.toPlainText().length +
        titleController.text.length;
    setState(() {
      wordNum = wordscount - 1;
    });
  }

  /// Build the background of the image based on the prefix of url/path.
  Widget buildNoteBackground(String path) {
    if (path.startsWith('http')) {
      return CachedNetworkImage(
          imageUrl: path,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) =>
              Icon(Icons.error, color: Theme.of(context).colorScheme.error));
    } else {
      final imageName = path.substring(25);
      final imageUrl =
          "https://raw.githubusercontent.com/stanlysilas/bloom_data/refs/heads/main/backgrounds/$imageName";
      return CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) =>
              Icon(Icons.error, color: Theme.of(context).colorScheme.error));
    }
  }

  @override
  Widget build(BuildContext mainContext) {
    final focusProvider = Provider.of<EditorFocusProvider>(context);
    return Scaffold(
      key: _scaffold,
      extendBody: true,
      appBar: AppBar(
        leading: IconButton(
            style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.surfaceContainer)),
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back, color: Colors.grey)),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              Provider.of<EmojiNotifier>(context).emoji.toString(),
            ),
            const SizedBox(
              width: 3,
            ),
            Expanded(
              child: Text(
                  widget.title!.isEmpty || widget.title == null
                      ? 'Untitled'
                      : widget.title!,
                  style: TextStyle(
                      fontFamily: 'ClashGrotesk', fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        actions: [
          // Sync status of the entry
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
                        color: Theme.of(context).colorScheme.surfaceContainer,
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
                        color: Theme.of(context).colorScheme.surfaceContainer,
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
          // More options button
          Padding(
            padding: const EdgeInsets.only(top: 2.0, right: 4),
            child: IconButton(
              tooltip: 'Menu',
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                      Theme.of(context).colorScheme.surfaceContainer)),
              onPressed: () async {
                countWords(); // Perform the count only when tapped.
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (BuildContext context) {
                    return MoreEntryOptions(
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
                      titleController: titleController,
                    );
                  },
                  showDragHandle: true,
                );
              },
              icon: const Icon(Icons.more_horiz_rounded, color: Colors.grey),
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
                              from: 'note',
                              backgroundImageNotifier:
                                  backgroundImageNotifier))),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: Provider.of<BackgroundImageNotifier>(context)
                                    .backgroundImageUrl ==
                                ''
                            ? 0
                            :
                            // : defaultTargetPlatform == TargetPlatform.android
                            // ?
                            MediaQuery.of(context).size.height * 0.22,
                        // : defaultTargetPlatform ==
                        //             TargetPlatform.windows ||
                        //         kIsWeb ||
                        //         defaultTargetPlatform ==
                        //             TargetPlatform.macOS ||
                        //         defaultTargetPlatform ==
                        //             TargetPlatform.linux
                        //     ? MediaQuery.of(context).size.height * 0.3
                        //     : MediaQuery.of(context).size.height * 0.22,
                        child: Provider.of<BackgroundImageNotifier>(context)
                                    .backgroundImageUrl ==
                                ''
                            ? const SizedBox()
                            : buildNoteBackground(
                                    Provider.of<BackgroundImageNotifier>(
                                            context)
                                        .backgroundImageUrl
                                        .toString())
                                .animate()
                                .fadeIn(
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
                            ? const EdgeInsets.symmetric(horizontal: 8)
                            : const EdgeInsets.symmetric(horizontal: 250),
                        child: Material(
                          borderRadius: BorderRadius.circular(24),
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () =>
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => EntriesIconPicker(
                                          from: 'note',
                                          icon: emoji,
                                          iconNotifier: emojiNotifier,
                                        ))),
                            // Emoji container
                            child: Container(
                              height: 70,
                              width: 70,
                              alignment: Alignment.center,
                              child: Text(
                                Provider.of<EmojiNotifier>(context)
                                    .emoji
                                    .toString(),
                                style: const TextStyle(fontSize: 45),
                              ),
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
                          child: Material(
                            borderRadius: BorderRadius.circular(4),
                            color:
                                Theme.of(context).colorScheme.surfaceContainer,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(4),
                              onTap: () =>
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => EntriesIconPicker(
                                            from: 'note',
                                            icon: emoji,
                                            iconNotifier: emojiNotifier,
                                          ))),
                              child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Text(
                                    'Add icon',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant),
                                  )),
                            ),
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
                autoFocus: false,
                hintText: 'Title',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyMedium?.color),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            // Description of the note should be displayed here
            Container(
              width: MediaQuery.of(context).size.width,
              padding: MediaQuery.of(context).size.width < mobileWidth
                  ? const EdgeInsets.all(0)
                  : const EdgeInsets.symmetric(horizontal: 250),
              child: QuillEditor(
                focusNode: focusProvider.editorFocusNode,
                scrollController: ScrollController(),
                controller: descriptionController,
                config: QuillEditorConfig(
                    padding:
                        const EdgeInsets.only(left: 12, right: 12, bottom: 10),
                    scrollable: false,
                    requestKeyboardFocusOnCheckListChanged: true,
                    placeholder: 'Start typing here',
                    enableScribble: true,
                    onTapOutsideEnabled: true,
                    // onTapOutside: (event, focusNode) {
                    //   focusNode.unfocus();
                    // },
                    onScribbleActivated: () {
                      // Add the functionality for writing with apple pencil and others here
                    },
                    scrollBottomInset: 100),
              ),
            ),
            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
      bottomSheet: isEditing == true || focusProvider.editorFocusNode.hasFocus
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer),
                child: Row(
                  children: [
                    // Bloom AI button
                    // IconButton(
                    //   onPressed: () {
                    //     setState(() {
                    //       focusProvider.unfocusEditor();
                    //       textFormatEnabled = false;
                    //       bloomAIEnabled = !bloomAIEnabled;
                    //     });
                    //     // Show a bottomSheet with the TextField for Google Gemini
                    //     showBloomAI(context);
                    //   },
                    //   icon: Icon(Icons.g_mobiledata_rounded),
                    // ),
                    // Text formatting options button
                    IconButton(
                      onPressed: () {
                        setState(() {
                          textFormatEnabled = !textFormatEnabled;
                          bloomAIEnabled = false;
                          focusProvider.editorFocusNode.requestFocus();
                        });
                      },
                      icon: Icon(textFormatEnabled
                          ? Icons.close_rounded
                          : Icons.format_size_rounded),
                    ),
                    if (textFormatEnabled)
                      Expanded(
                        child: CustomHorizontalTextEditingToolbar(
                          controller: descriptionController,
                          focusNode: focusProvider.editorFocusNode,
                        ),
                      ),
                    const SizedBox(
                      height: 28,
                      child: VerticalDivider(
                        width: 2,
                      ),
                    ),
                    if (focusProvider.editorFocusNode.hasFocus || isEditing)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isEditing = false;
                            focusProvider.unfocusEditor();
                            titleFocusNode.unfocus();
                          });
                        },
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      ),
                  ],
                ).animate().fade(
                    delay: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut),
              ),
            )
          : const SizedBox(),
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
    );
    dummyFocusNode.requestFocus();
    editorFocusNode.unfocus();
    notifyListeners();
  }

  @override
  void dispose() {
    editorFocusNode.dispose();
    dummyFocusNode.dispose();
    super.dispose();
  }
}
