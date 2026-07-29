import 'package:bloom/features/objects/shared/widgets/objects_tile.dart';
import 'package:bloom/features/objects/books/widgets/book_pages_loading_state.dart';
import 'package:bloom/features/objects/books/widgets/book_pages_empty_state.dart';
import 'package:bloom/models/bloom_object_model.dart';
import 'package:bloom/models/book_model.dart';
import 'package:bloom/services/firebase/parent_object_service.dart';
import 'package:flutter/material.dart';

class BookPages extends StatefulWidget {
  final BookModel bookModel;
  final bool isSearchToggled;
  final String searchText;
  const BookPages(
      {super.key,
      required this.bookModel,
      required this.isSearchToggled,
      required this.searchText});

  @override
  State<BookPages> createState() => _BookPagesState();
}

class _BookPagesState extends State<BookPages> {
  final parentObjectService = ParentObjectService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BloomObjectModel>>(
        stream: parentObjectService.streamBookObjects(
            widget.bookModel.objectId!,
            widget.isSearchToggled,
            widget.searchText),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  height: constraints.maxHeight.isInfinite
                      ? 300
                      : constraints.maxHeight,
                  width: constraints.maxWidth.isInfinite
                      ? double.infinity
                      : constraints.maxWidth,
                  child: const BookPagesLoadingState(),
                );
              },
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                  'An error occurred while fetching pages for ${widget.bookModel.title}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const BookPagesEmptyState();
          }

          final entriesList = snapshot.data!;
          return ListView.builder(
            itemCount: entriesList.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final bloomObject = entriesList[index];
              return ObjectsTile(
                bloomObject: bloomObject,
                innerPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              );
            },
          );
        });
  }
}
