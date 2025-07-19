import 'dart:async';
import 'dart:convert';

import 'package:bloom/components/custom_textediting_toolbar.dart';
import 'package:bloom/components/textfield_nobackground.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';

class BookEntry extends StatefulWidget {
  final String? mainBookId;
  final String? mainBookEmoji;
  final String mainBookTitle;
  final String? mainBookDescription;
  final String mainType;
  final String? entryId;
  final String? entryEmoji;
  final String entryTitle;
  final String entryContent;
  final DateTime dateTime;
  final bool? mainBookHasChildren;
  final bool? isFavorite;
  final List? attachments;
  final List? mainBookChildren;
  final BookMode mode;
  const BookEntry(
      {super.key,
      required this.dateTime,
      this.isFavorite,
      this.attachments,
      required this.mode,
      this.mainBookId,
      this.mainBookEmoji,
      required this.mainBookTitle,
      required this.mainType,
      this.entryId,
      this.entryEmoji,
      required this.entryTitle,
      required this.entryContent,
      this.mainBookHasChildren,
      this.mainBookChildren,
      this.mainBookDescription});

  @override
  State<BookEntry> createState() => _BookEntryState();
}

// Enum to represent different modes
enum BookMode { create, display, edit }

class _BookEntryState extends State<BookEntry> {
  // Required variables
  bool isEditing = false;
  late String mainBookId;
  late TextEditingController emojiController;
  late TextEditingController titleController;
  late QuillController contentController;
  final titleFocusNode = FocusNode();
  final contentFocusNode = FocusNode();
  Timer? saveTimer;
  final user = FirebaseAuth.instance.currentUser;

  // Method to initialize the variables and methods
  @override
  void initState() {
    super.initState();
    emojiController = TextEditingController(text: widget.entryEmoji ?? '');
    titleController = TextEditingController(text: widget.entryTitle);
    mainBookId = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('entries')
        .doc()
        .id;
    final description = getDocumentFromDescription(widget.entryContent);
    contentController = QuillController(
      document: description,
      selection: const TextSelection.collapsed(offset: 0),
    );
    // Adding listeners to the required variables
    titleController.addListener(onDataChanged);
    contentController.addListener(onDataChanged);
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

  // Method to check the changes in the entry
  void onDataChanged() {
    if (mounted) {
      setState(() {
        isEditing = jsonEncode(contentController.document.toDelta().toJson()) !=
            widget.entryContent;
      });
    }
    scheduleSave();
  }

  // Schedule save with a delay to avoid excessive writes
  void scheduleSave() {
    saveTimer?.cancel();
    saveTimer = Timer(const Duration(milliseconds: 1500), saveBookData);
  }

  // Method to save all the data of the note into the database
  Future saveBookData() async {
    if (widget.mainBookId == 'default' &&
        contentController.document.isEmpty() == false) {
      final firestore = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('entries');
      await firestore.doc(mainBookId).set({
        'addedOn': widget.dateTime,
        'mainEntryId': mainBookId,
        'mainEntryEmoji': widget.mainBookEmoji,
        'mainEntryTitle': widget.mainBookTitle,
        'mainEntryType': widget.mainType,
        'mainEntryDescription': widget.mainBookDescription,
      }, SetOptions(merge: true));
      // Saving the child entry
      final String childId = FirebaseFirestore.instance
          .collection('users')
          .doc(mainBookId)
          .collection('entries')
          .doc()
          .id;
      var content = jsonEncode(contentController.document.toDelta().toJson());
      await firestore.doc(mainBookId).collection('children').doc(childId).set({
        'addedOn': widget.dateTime,
        'entryContent': content,
        'entryTitle': titleController.text,
        'entryEmoji': emojiController.text,
      }, SetOptions(merge: true));
    } else {
      final firestore = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('entries');
      await firestore.doc(mainBookId).set({
        'addedOn': widget.dateTime,
        'mainEntryId': mainBookId,
        'mainEntryEmoji': widget.mainBookEmoji,
        'mainEntryTitle': widget.mainBookTitle,
        'mainEntryType': widget.mainType,
        'mainEntryDescription': widget.mainBookDescription,
      }, SetOptions(merge: true));
      // Saving the child entry
      final String childId = FirebaseFirestore.instance
          .collection('users')
          .doc(mainBookId)
          .collection('entries')
          .doc()
          .id;
      var content = jsonEncode(contentController.document.toDelta().toJson());
      await firestore.doc(mainBookId).collection('children').doc(childId).set({
        'addedOn': widget.dateTime,
        'entryContent': content,
        'entryTitle': titleController.text,
        'entryEmoji': emojiController.text,
      }, SetOptions(merge: true));
    }
  }

  // Method to dispose off the used variables and other methods
  @override
  void dispose() {
    contentController.removeListener(onDataChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () {},
                    child: Text(
                      widget.entryEmoji ?? 'Emoji',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  Expanded(
                    child: MyTextfieldNobackground(
                      controller: titleController,
                      focusNode: FocusNode(),
                      readOnly: true,
                      hintText: '',
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: QuillEditor(
                  focusNode: contentFocusNode,
                  scrollController: ScrollController(),
                  controller: contentController,
                  config: QuillEditorConfig(
                      expands: true,
                      maxHeight: null,
                      minHeight: null,
                      checkBoxReadOnly: false,
                      onTapOutsideEnabled: true,
                      onTapOutside: (event, focusNode) {
                        focusNode.unfocus();
                        isEditing = false;
                      },
                      placeholder: 'Start typing...'),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: isEditing
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    // Text formatting options button
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          contentFocusNode.unfocus();
                          showModalBottomSheet(
                              context: context,
                              useSafeArea: true,
                              barrierColor: Colors.transparent,
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              builder: (context) {
                                return Container(
                                  width: double.maxFinite,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Colors.grey,
                                            offset: Offset(0, -6),
                                            blurRadius: 10)
                                      ],
                                      border: Border.all(
                                          color: Colors.grey, width: 0.5)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CustomTexteditingToolbar(
                                      controller: contentController,
                                      focusNode: contentFocusNode, onSelected: () {  },
                                    ),
                                  ),
                                );
                              });
                        },
                        borderRadius: BorderRadius.circular(1000),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1000),
                              color: Theme.of(context).primaryColorLight),
                          child: const Icon(Icons.text_fields_rounded),
                        ),
                      ),
                    ),
                    // Button for adding more types of data like images etc
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          contentFocusNode.unfocus();
                          showModalBottomSheet(
                              context: context,
                              useSafeArea: true,
                              barrierColor: Colors.transparent,
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              builder: (context) {
                                return Container(
                                  width: double.maxFinite,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Colors.grey,
                                            offset: Offset(0, -6),
                                            blurRadius: 10)
                                      ],
                                      border: Border.all(
                                          color: Colors.grey, width: 0.5)),
                                  child: const Center(
                                    child: Text(
                                      'Adding images, videos, links and other is not supported yet. Please wait for a future update. Thank you.',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              });
                        },
                        borderRadius: BorderRadius.circular(1000),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1000),
                              color: Theme.of(context).primaryColorLight),
                          child: const Icon(Icons.add_rounded),
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Button to close the keyboard and come out of editing mode
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          contentFocusNode.unfocus();
                          isEditing = false;
                        },
                        borderRadius: BorderRadius.circular(1000),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1000),
                              color: Theme.of(context).primaryColorLight),
                          child: const Icon(Icons.keyboard_arrow_down_rounded),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox(),
    );
  }
}
