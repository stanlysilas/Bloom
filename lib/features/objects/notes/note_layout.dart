import 'dart:convert';

import 'package:bloom/core/controllers/autosave_controller.dart';
import 'package:bloom/core/widgets/bloom_buttons.dart';
import 'package:bloom/core/widgets/sync_indicator.dart';
import 'package:bloom/features/objects/notes/widgets/custom_textediting_toolbar.dart';
import 'package:bloom/features/objects/notes/widgets/more_entry_options.dart';
import 'package:bloom/features/objects/notes/widgets/textfield_nobackground.dart';
import 'package:bloom/core/responsive/dimensions.dart';
import 'package:bloom/features/objects/screens/entries_background_images.dart';
import 'package:bloom/features/objects/screens/entries_icon_picker.dart';
import 'package:bloom/models/bloom_object_model.dart';
import 'package:bloom/models/note_model.dart';
import 'package:bloom/services/firebase/object_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:provider/provider.dart';

class NoteLayout extends StatefulWidget {
  final NoteModel noteModel;
  final NoteMode mode;
  const NoteLayout({
    super.key,
    required this.mode,
    required this.noteModel,
  });

  @override
  State<NoteLayout> createState() => _NoteLayoutState();
}

enum NoteMode { create, display, edit }

class _NoteLayoutState extends State<NoteLayout> {
  late NoteModel noteModel;
  late String objectId;
  bool showEditor = false;
  late TextEditingController searchEmojisController;
  late TextEditingController titleController;
  late QuillController descriptionController;
  final titleFocusNode = FocusNode();
  final autoSaveController = AutoSaveController();
  final objectService = ObjectService();

  @override
  void initState() {
    super.initState();
    noteModel = widget.noteModel;
    searchEmojisController = TextEditingController(text: noteModel.icon);
    titleController = TextEditingController(text: noteModel.title);
    final description = getDocumentFromDescription(noteModel.content);
    descriptionController = QuillController(
      document: description,
      selection: const TextSelection.collapsed(offset: 0),
    );
    descriptionController.addListener(onDataChanged);
    titleController.addListener(onDataChanged);
    noteModel.objectId =
        noteModel.objectId == null || noteModel.objectId!.isEmpty
            ? FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .collection('objects')
                .doc()
                .id
            : noteModel.objectId;
  }

  @override
  void dispose() {
    searchEmojisController.dispose();
    descriptionController.dispose();
    titleController.dispose();
    titleController.removeListener(onDataChanged);
    super.dispose();
  }

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

  void onDataChanged() {
    final isDirty =
        jsonEncode(descriptionController.document.toDelta().toJson()) !=
                noteModel.content ||
            widget.noteModel.backgroundImageUrl !=
                noteModel.backgroundImageUrl ||
            widget.noteModel.icon != noteModel.icon ||
            titleController.text != noteModel.title;
    if (!isDirty) {
      noteModel.isSyncing = false;
    }
    setState(() {
      noteModel.isSyncing = true;
      showEditor = true;
    });
    final newNoteModel = noteModel.copyWith(
        parentType: widget.noteModel.parentType,
        objectId: noteModel.objectId,
        icon: noteModel.icon,
        title: titleController.text.trim(),
        content: jsonEncode(descriptionController.document.toDelta().toJson()),
        backgroundImageUrl: noteModel.backgroundImageUrl);
    autoSaveController.schedule(const Duration(milliseconds: 1500), () async {
      await objectService.updateObject(newNoteModel).then((_) {
        setState(() {
          noteModel = newNoteModel;
          noteModel.isSyncing = false;
        });
      });
    });
  }

  int wordNum = 0;

  void countWords() {
    int wordscount = descriptionController.document.toPlainText().length +
        titleController.text.length;
    setState(() {
      wordNum = wordscount - 1;
    });
  }

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
      extendBody: true,
      appBar: AppBar(
        leading: IconButton(
            style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.surfaceContainer)),
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back, color: Colors.grey)),
        actions: [
          SyncIndicator(isSyncing: noteModel.isSyncing),
          const SizedBox(
            width: 6,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2.0, right: 4),
            child: BloomIconButton(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              onTap: () async {
                countWords();
                final updatedObject =
                    await showModalBottomSheet<BloomObjectModel>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (BuildContext context) {
                    return MoreEntryOptions(
                      bloomObject: noteModel,
                    );
                  },
                  showDragHandle: true,
                );
                if (updatedObject != null && updatedObject is NoteModel) {
                  setState(() {
                    noteModel = updatedObject;
                  });
                  onDataChanged();
                }
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
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        final newBackgroundImageUrl = await Navigator.of(
                                context)
                            .push<String>(MaterialPageRoute(
                                fullscreenDialog: true,
                                builder: (context) => EntriesBackgroundImages(
                                      backgroundImageUrl:
                                          noteModel.backgroundImageUrl,
                                    )));
                        if (newBackgroundImageUrl != null) {
                          noteModel.copyWith(
                              backgroundImageUrl: newBackgroundImageUrl);
                          onDataChanged();
                        }
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: noteModel.backgroundImageUrl.isEmpty
                            ? 0
                            : MediaQuery.of(context).size.height * 0.25,
                        child: noteModel.backgroundImageUrl.isEmpty
                            ? const SizedBox()
                            : buildNoteBackground(noteModel.backgroundImageUrl),
                      ),
                    ),
                    SizedBox(
                      height: 36,
                      width: MediaQuery.of(context).size.width,
                    )
                  ],
                ),
                noteModel.icon.isEmpty
                    ? const SizedBox()
                    : Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                          padding: MediaQuery.of(context).size.width < mobileWidth
                              ? const EdgeInsets.symmetric(horizontal: 8)
                              : const EdgeInsets.symmetric(horizontal: 250),
                          child: Material(
                            borderRadius: BorderRadius.circular(24),
                            color: Theme.of(context).colorScheme.surfaceContainer,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () async {
                                final newIcon = await Navigator.push<String>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EntriesIconPicker(
                                      icon: noteModel.icon,
                                    ),
                                  ),
                                );
                      
                                if (newIcon != null) {
                                  setState(() {
                                    noteModel = noteModel.copyWith(icon: newIcon);
                                  });
                                  onDataChanged();
                                }
                              },
                              child: Container(
                                height: 70,
                                width: 70,
                                alignment: Alignment.center,
                                child: Text(
                                  noteModel.icon,
                                  style: const TextStyle(fontSize: 45),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ),
              ],
            ),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: MediaQuery.of(context).size.width > mobileWidth
                    ? 650
                    : null,
                child: Row(
                  children: [
                    noteModel.icon.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 2),
                            child: Material(
                              borderRadius: BorderRadius.circular(4),
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainer,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(4),
                                onTap: () async {
                                  final newIcon = await Navigator.push<String>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EntriesIconPicker(
                                        icon: noteModel.icon,
                                      ),
                                    ),
                                  );

                                  if (newIcon != null) {
                                    setState(() {
                                      noteModel =
                                          noteModel.copyWith(icon: newIcon);
                                    });
                                    onDataChanged();
                                  }
                                },
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
            ),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: MediaQuery.of(context).size.width > mobileWidth
                    ? 650
                    : null,
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
            ),
            const SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: MediaQuery.of(context).size.width > mobileWidth
                    ? 660
                    : null,
                child: QuillEditor(
                  focusNode: focusProvider.editorFocusNode,
                  scrollController: ScrollController(),
                  controller: descriptionController,
                  config: QuillEditorConfig(
                      padding: const EdgeInsets.only(
                          left: 12, right: 12, bottom: 10),
                      scrollable: false,
                      requestKeyboardFocusOnCheckListChanged: true,
                      placeholder: 'Start typing here',
                      enableScribble: true,
                      onTapOutsideEnabled: true,
                      scrollBottomInset: 100),
                ),
              ),
            ),
            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
      bottomSheet: focusProvider.editorFocusNode.hasFocus
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          showEditor = false;
                          focusProvider.editorFocusNode.requestFocus();
                        });
                      },
                      icon: Icon(showEditor
                          ? Icons.close_rounded
                          : Icons.format_size_rounded),
                    ),
                    if (showEditor)
                      Expanded(
                        child: CustomHorizontalTextEditingToolbar(
                          controller: descriptionController,
                        ),
                      ),
                    const SizedBox(
                      height: 28,
                      child: VerticalDivider(
                        width: 2,
                      ),
                    ),
                    if (focusProvider.editorFocusNode.hasFocus)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            showEditor = false;
                            focusProvider.unfocusEditor();
                            titleFocusNode.unfocus();
                          });
                        },
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      ),
                  ],
                ),
              ),
            )
          : const SizedBox(),
    );
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
