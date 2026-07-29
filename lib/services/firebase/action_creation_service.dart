import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ActionCreationService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String get _uid => _auth.currentUser!.uid;

  static Future<void> createTask({
    required String name,
    required String description,
    required DateTime dateTime,
    required List<String> groups,
    required int priorityLevel,
    required int uniqueId,
  }) async {
    final id = _db.collection('users').doc(_uid).collection('tasks').doc().id;

    await _db.collection('users').doc(_uid).collection('tasks').doc(id).set({
      'objectId': id,
      'actionObjectType': 'task',
      'name': name,
      'description': description,
      'dateTime': dateTime,
      'endDateTime': null,
      'isCompleted': false,
      'priorityLevel': priorityLevel,
      'groups': groups,
      'uniqueNotificationId': uniqueId,
      'addedOn': DateTime.now(),
    });
  }

  static Future<void> createHabit({
    required String name,
    required String description,
    required DateTime dateTime,
    required List<int> daysOfWeek,
    required List<String> groups,
    required int uniqueId,
  }) async {
    final id = _db.collection('users').doc(_uid).collection('habits').doc().id;

    await _db.collection('users').doc(_uid).collection('habits').doc(id).set({
      'objectId': id,
      'actionObjectType': 'habit',
      'name': name,
      'description': description,
      'dateTime': dateTime,
      'isCompleted': false,
      'completedDates': [],
      'daysOfWeek': daysOfWeek,
      'groups': groups,
      'uniqueNotificationId': uniqueId,
      'addedOn': DateTime.now(),
    });
  }
}
