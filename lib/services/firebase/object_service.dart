import 'package:bloom/core/utils/object_factory.dart';
import 'package:bloom/models/bloom_object_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ObjectService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> objectsRef() {
    return _db
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('objects');
  }

  CollectionReference<Map<String, dynamic>> entriesRef() {
    return _db
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('entries');
  }

  CollectionReference<Map<String, dynamic>> booksRef() {
    return _db
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('books');
  }

  Stream<List<BloomObjectModel>> fetchObjects(String sortValue) {
    return Rx.combineLatest3(
      booksRef().snapshots(),
      objectsRef().snapshots(),
      entriesRef().snapshots(),
      (booksSnap, objectsSnap, entriesSnap) {
        final books = booksSnap.docs.map((doc) {
          final data = doc.data();
          data['objectId'] = doc.id;
          return ObjectFactory.fromFirestore(data);
        }).toList();

        final objects = objectsSnap.docs.map((doc) {
          final data = doc.data();
          data['objectId'] = doc.id;
          return ObjectFactory.fromFirestore(data);
        }).toList();

        final entries = entriesSnap.docs.map((doc) {
          final data = doc.data();
          data['objectId'] = doc.id;
          return ObjectFactory.fromFirestore(data);
        }).toList();

        var combined = [...books, ...objects, ...entries];

        switch (sortValue) {
          case 'Oldest':
            combined.sort((a, b) => a.dateTime.compareTo(b.dateTime));
            break;

          case 'Favorites':
            combined = combined.where((e) => e.isFavorite).toList();
            break;

          case 'Recents':
          default:
            combined.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        }

        return combined;
      },
    );
  }

  // Future<void> saveObject(BloomObjectModel bloomObject) async {
  //   if (bloomObject.objectId == null) {
  //     throw Exception('ObjectId cannot be null when saving an object');
  //   }

  //   final parentType = bloomObject.parentType;

  //   switch (parentType) {
  //     case null:
  //     case BloomObjectType.note:
  //       await objectsRef()
  //           .doc(bloomObject.objectId)
  //           .set(bloomObject.toFirestore(), SetOptions(merge: true));
  //       break;

  //     default:
  //       if (bloomObject.parentId == null) {
  //         throw Exception('ParentId cannot be null when saving a nested object object');
  //       }

  //       await objectsRef()
  //           .doc(bloomObject.parentId)
  //           .collection('objects')
  //           .doc(bloomObject.objectId)
  //           .set(bloomObject.toFirestore(), SetOptions(merge: true));
  //   }
  // }

  Future<void> updateObject(BloomObjectModel bloomObject) async {
    if (bloomObject.objectId == null) {
      throw Exception('ObjectId cannot be null when updating an object');
    }

    final parentId = bloomObject.parentId;
    final collectionRef = objectsRef().doc(bloomObject.objectId).id;

    if (parentId == null) {
      if (collectionRef.isEmpty) {
        debugPrint("CollectionRef is empty for this object.");
      }
      await objectsRef()
          .doc(bloomObject.objectId)
          .set(bloomObject.toFirestore(), SetOptions(merge: true));

      await entriesRef().doc(bloomObject.objectId).delete();
    } else {
      await objectsRef()
          .doc(parentId)
          .collection('objects')
          .doc(bloomObject.objectId)
          .set(bloomObject.toFirestore(), SetOptions(merge: true));

      await booksRef()
          .doc(parentId)
          .collection('pages')
          .doc(bloomObject.objectId)
          .delete();
    }
  }

  Future<void> updateLockState(String objectId, bool value) async {
    await objectsRef().doc(objectId).update({
      'isLocked': value,
    });
  }

  Future<void> updateFavoriteState(String objectId, bool value) async {
    await objectsRef().doc(objectId).update({
      'isFavorite': value,
    });
  }

  Future<void> deleteObject(BloomObjectModel object) async {
    try {
      if (object.parentType == BloomObjectType.book &&
          object.parentId != null) {
        await objectsRef()
            .doc(object.parentId)
            .collection('objects')
            .doc(object.objectId)
            .delete();
        return;
      }

      await objectsRef().doc(object.objectId).delete();

      await booksRef().doc(object.objectId).delete();

      await entriesRef().doc(object.objectId).delete();

      final books = await booksRef().get();

      for (final book in books.docs) {
        await book.reference.collection('pages').doc(object.objectId).delete();
      }
    } catch (e) {
      throw Exception('Delete failed: $e');
    }
  }
}
