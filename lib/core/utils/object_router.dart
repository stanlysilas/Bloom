import 'package:bloom/features/objects/books/book_layout.dart';
import 'package:bloom/models/bloom_object_model.dart';
import 'package:bloom/features/objects/notes/note_layout.dart';
import 'package:bloom/models/book_model.dart';
import 'package:bloom/models/note_model.dart';
import 'package:flutter/material.dart';

class ObjectRouter {
  static Future<void> open(
      BuildContext context, BloomObjectModel object) async {
    switch (object.type) {
      case 'note':
        final note = object as NoteModel;
        debugPrint('Navigating with NoteModel type');

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NoteLayout(
              mode: NoteMode.edit,
              noteModel: note,
            ),
          ),
        );
        break;
      case 'book':
        final book = object as BookModel;
        debugPrint('Navigating with BookModel type');

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookLayout(bookModel: book),
          ),
        );
        break;

      default:
        throw Exception('No screen registered for type: ${object.type}');
    }
  }
}
