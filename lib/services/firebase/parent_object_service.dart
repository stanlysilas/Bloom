import 'package:async/async.dart';
import 'package:bloom/core/utils/object_factory.dart';
import 'package:bloom/models/bloom_object_model.dart';
import 'package:bloom/models/book_model.dart';
import 'package:bloom/models/note_model.dart';
import 'package:bloom/features/objects/notes/note_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ParentObjectService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> objectsRef() {
    return _db
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('objects');
  }

  CollectionReference<Map<String, dynamic>> booksRef() {
    return _db
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('books');
  }

  Stream<List<BookModel>> fetchBooks() {
    return StreamZip([
      booksRef().snapshots(),
      objectsRef().where('objectType', isEqualTo: 'book').snapshots()
    ]).map((snapshots) {
      final booksSnap = snapshots[0];
      final objectsSnap = snapshots[1];

      final books = booksSnap.docs
          .map((doc) => BookModel.fromFirestore(doc.data()))
          .toList();
      final objects = objectsSnap.docs
          .map((doc) => BookModel.fromFirestore(doc.data()))
          .toList();

      return [...books, ...objects];
    });
  }

  Future<void> saveBook(BookModel bookModel) async {
    await objectsRef().doc(bookModel.parentId).set(bookModel.toFirestore());
  }

  Future<void> updateBook(BookModel bookModel) async {
    if (bookModel.parentId == null || bookModel.parentId!.isEmpty) {
      debugPrint("BookModel parentId is null or empty");
    }

    await objectsRef()
        .doc(bookModel.objectId)
        .set(bookModel.toFirestore(), SetOptions(merge: true));
  }

  Future<void> createNewObject(BuildContext context,
      BloomObjectModel parentObject, BloomObjectType bloomObjectType) async {
    final type = bloomObjectType;

    switch (type) {
      case BloomObjectType.note:
        final newNote = NoteModel.create(
          parentId: parentObject.objectId,
          parentType: parentObject.bloomObjectType,
          objectId: '',
        );

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NoteLayout(
              mode: NoteMode.create,
              noteModel: newNote,
            ),
          ),
        );
        break;

      case BloomObjectType.book:
        debugPrint(
            "Creating a book inside another object is not yet supported.");
        break;

      default:
        throw Exception("Unsupported object type ${parentObject.type}");
    }
  }

  Stream<List<BloomObjectModel>> streamBookObjects(
    String bookId,
    bool isSearchEnabled,
    String searchQuery,
  ) {
    final objectsQuery = objectsRef().doc(bookId).collection('objects');
    final pagesQuery = booksRef().doc(bookId).collection('pages');

    Query<Map<String, dynamic>> firestoreQuery;

    if (isSearchEnabled && searchQuery.isNotEmpty) {
      firestoreQuery = objectsQuery
          .orderBy('title')
          .where('title', isGreaterThanOrEqualTo: searchQuery)
          .where('title', isLessThanOrEqualTo: '$searchQuery\uf8ff');
    } else {
      firestoreQuery = objectsQuery.orderBy('dateTime', descending: true);
    }

    final objectsStream = firestoreQuery.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['objectId'] = doc.id;
        debugPrint('ParentType: ${doc['parentType']}');
        return ObjectFactory.fromFirestore(data);
      }).toList();
    });

    final pagesStream = pagesQuery.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['pageId'] = doc.id;
        return ObjectFactory.fromFirestore(data);
      }).toList();
    });

    return StreamZip([objectsStream, pagesStream]).map((streams) {
      final objects = streams[0];
      final pages = streams[1];
      return [...objects, ...pages];
    });
  }

  Future<void> deleteBook(String bookId) async {
    await booksRef().doc(bookId).delete();
  }

  Future<void> deleteBookObject(String bookId, String objectId) async {
    await booksRef().doc(bookId).collection('objects').doc(objectId).delete();
  }

  Future<void> updateBookLockState(String bookId, bool value) async {
    await booksRef().doc(bookId).update({'isBookLocked': value});
  }

  Future<void> updateBookObjectLockState(
      String bookId, String objectId, bool value) async {
    await booksRef()
        .doc(bookId)
        .collection('objects')
        .doc(objectId)
        .update({'isLocked': value});
  }

  Future<void> updateBookObjectFavoriteState(
      String bookId, String objectId, bool value) async {
    await booksRef()
        .doc(bookId)
        .collection('objects')
        .doc(objectId)
        .update({'isFavorite': value});
  }
}
