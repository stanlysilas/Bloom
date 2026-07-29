import 'package:bloom/core/utils/action_object_factory.dart';
import 'package:bloom/models/action_object_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class ActionObjectService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> tasksRef() {
    return _db
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('tasks');
  }

  CollectionReference<Map<String, dynamic>> habitsRef() {
    return _db
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('habits');
  }

  CollectionReference<Map<String, dynamic>> eventsRef() {
    return _db
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('events');
  }

  Stream<List<ActionObjectModel>> fetchActionObjects() {
    return Rx.combineLatest3(
      tasksRef().snapshots(),
      habitsRef().snapshots(),
      eventsRef().snapshots(),
      (tasksSnapshot, habitsSnapshot, eventsSnapshot) {
        try {
          final tasks = tasksSnapshot.docs.map((doc) {
            final data = doc.data();
            data['objectId'] = doc.id;
            return ActionObjectFactory.fromFirestore(data);
          }).toList();

          final habits = habitsSnapshot.docs.map((doc) {
            final data = doc.data();
            data['objectId'] = doc.id;
            return ActionObjectFactory.fromFirestore(data);
          }).toList();

          final events = eventsSnapshot.docs.map((doc) {
            final data = doc.data();
            data['objectId'] = doc.id;
            return ActionObjectFactory.fromFirestore(data);
          }).toList();

          final combined = [...tasks, ...habits, ...events];

          combined.sort((a, b) => b.dateTime.compareTo(a.dateTime));

          return combined;
        } catch (e, stack) {
          print('🔥 STREAM ERROR: $e');
          print(stack);
          return <ActionObjectModel>[];
        }
      },
    );
  }
}
