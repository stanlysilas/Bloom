import 'package:bloom/core/controllers/autosave_controller.dart';
import 'package:bloom/core/widgets/sync_indicator.dart';
import 'package:bloom/features/objects/books/widgets/book_more_options_modal_sheet.dart';
import 'package:bloom/features/objects/books/widgets/book_pages.dart';
import 'package:bloom/features/objects/notes/widgets/textfield_nobackground.dart';
import 'package:bloom/models/bloom_object_model.dart';
import 'package:bloom/models/book_model.dart';
import 'package:bloom/core/responsive/dimensions.dart';
import 'package:bloom/services/firebase/parent_object_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BookLayout extends StatefulWidget {
  final BookModel bookModel;
  final bool? isFirstTime;
  const BookLayout({
    super.key,
    required this.bookModel,
    this.isFirstTime,
  });

  @override
  State<BookLayout> createState() => _BookLayoutState();
}

class _BookLayoutState extends State<BookLayout> {
  bool isSearchToggled = false;
  late BookModel bookModel;
  late TextEditingController titleController;
  final searchController = TextEditingController();
  late TextEditingController descriptionController;
  final titleFocusNode = FocusNode();
  final descriptionFocusNode = FocusNode();
  final searchFocusNode = FocusNode();
  final parentObjectService = ParentObjectService();
  final autoSaveController = AutoSaveController();

  @override
  void initState() {
    super.initState();
    if (widget.bookModel.objectId == null) {
      widget.bookModel.objectId = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('books')
          .doc()
          .id;
    }
    titleController = TextEditingController(text: widget.bookModel.title);
    descriptionController =
        TextEditingController(text: widget.bookModel.content);
    bookModel = widget.bookModel;
    titleController.addListener(onDataChanged);
    descriptionController.addListener(onDataChanged);
  }

  void onDataChanged() {
    final isDirty = titleController.text.trim() != bookModel.title ||
        descriptionController.text.trim() != bookModel.content;

    if (!isDirty) {
      bookModel.isSyncing = false;
    }

    setState(() {
      bookModel.isSyncing = true;
    });

    final newBookModel = bookModel.copyWith(
      title: titleController.text.trim(),
      content: descriptionController.text.trim(),
    );

    autoSaveController.schedule(
      const Duration(milliseconds: 1500),
      () async {
        await parentObjectService.updateBook(newBookModel).then((_) {
          setState(() {
            bookModel = newBookModel;
            bookModel.isSyncing = false;
          });
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
    searchController.dispose();
    titleFocusNode.dispose();
    descriptionFocusNode.dispose();
    searchFocusNode.dispose();
    autoSaveController.cancel();
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
            SyncIndicator(isSyncing: bookModel.isSyncing),
            const SizedBox(
              width: 6,
            ),
            if (widget.isFirstTime != null && widget.isFirstTime! == false)
              IconButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                        Theme.of(context).colorScheme.surfaceContainer)),
                onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    useSafeArea: true,
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.6),
                    builder: (_) => BookMoreOptionsModalSheet()),
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
            spacing: 14,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: MyTextfieldNobackground(
                  controller: titleController,
                  focusNode: titleFocusNode,
                  autoFocus: false,
                  minLines: 1,
                  maxLines: 3,
                  readOnly: false,
                  hintText: 'Title',
                  style: TextStyle(fontSize: 22),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: MyTextfieldNobackground(
                    controller: descriptionController,
                    focusNode: descriptionFocusNode,
                    hintText: 'Short description',
                    autoFocus: false,
                    readOnly: false),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    !isSearchToggled
                        ? InkWell(
                            onTap: () => setState(
                                () => isSearchToggled = !isSearchToggled),
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
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => parentObjectService.createNewObject(
                          context, widget.bookModel, BloomObjectType.note),
                      child: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: BookPages(
                    bookModel: widget.bookModel,
                    isSearchToggled: isSearchToggled,
                    searchText: searchController.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
