import 'package:bloom/models/bloom_object_model.dart';
import 'package:bloom/models/book_model.dart';
import 'package:bloom/models/note_model.dart';
import 'package:bloom/services/firebase/migration_services.dart';
import 'package:flutter/material.dart';

class ObjectFactory {
  static BloomObjectModel fromFirestore(Map<String, dynamic> doc) {
    final type = doc['objectType'] ??
        doc['pageType'] ??
        doc['mainEntryType'] ??
        doc['type'];

    if (type == 'book' && doc.containsKey('pageDescription')) {
      MigrationServices.migrateLegacyBookPages();
    }

    if (doc['parentType'] == null && doc['parentId'] != null) {
      debugPrint(
          "Running migration services for null parentType fields of child objects");
      MigrationServices.migrateNullParentTypeFields(doc['parentType']);
    }

    switch (type) {
      case 'note':
        return NoteModel.fromFirestore(doc);
      case 'book':
        return BookModel.fromFirestore(doc);

      default:
        throw Exception('Unsupported object type: $type');
    }
  }
}
