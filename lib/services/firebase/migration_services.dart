import 'package:bloom/models/bloom_object_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MigrationServices {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<void> migrateLegacyBookPages() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final booksSnapshot =
        await _db.collection('users').doc(user.uid).collection('books').get();

    for (final bookDoc in booksSnapshot.docs) {
      final pagesSnapshot = await bookDoc.reference.collection('pages').get();

      for (final pageDoc in pagesSnapshot.docs) {
        final data = pageDoc.data();

        if (data['pageType'] == 'book') {
          await pageDoc.reference.update({
            'pageType': 'note',
          });
        }
      }
    }
  }

  static Future<void> migrateNullParentTypeFields(
      BloomObjectModel parentObject) async {
    final collectionRef = _db
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('objects')
        .doc(parentObject.objectId)
        .collection('objects');

    final snapshot = await collectionRef.get();

    final batch = _db.batch();

    for (final doc in snapshot.docs) {
      final data = doc.data();

      if (data['parentType'] == null) {
        batch.update(doc.reference, {
          'parentType': parentObject.bloomObjectType.name,
        });
      }
    }

    await batch.commit();
  }

  /// Migrate the Title's of old Tasks, Habits and Events to support
  /// the new Fuzzy search logic.
  Future<void> migrateLowercaseFields(String type) async {
    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection(type);

    final snapshot = await collection.get();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final fieldName = {
        'tasks': 'taskName',
        'habits': 'habitName',
        'events': 'eventName',
      }[type];

      if (fieldName != null &&
          data[fieldName] != null &&
          data['${fieldName}_lower'] == null) {
        await doc.reference.update({
          '${fieldName}_lower': data[fieldName].toString().toLowerCase(),
        });
      }
    }
  }
}
