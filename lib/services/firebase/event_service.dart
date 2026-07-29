import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bloom/models/event_model.dart';
import 'package:bloom/services/firebase/notification.dart';
import 'package:bloom/services/audio/audio_manager.dart';

class EventService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String get _uid => _auth.currentUser!.uid;

  static DocumentReference<Map<String, dynamic>> _eventRef(String id) {
    return _db.collection('users').doc(_uid).collection('events').doc(id);
  }

  static Future<void> markAttended(EventModel event) async {
    await _eventRef(event.objectId).update({
      'isAttended': true,
    });

    await NotificationService.cancelNotification(
        event.uniqueNotificationId ?? 0);

    AudioManager().playTaskCompleted();

    final completedDate = DateTime(
      event.dateTime.year,
      event.dateTime.month,
      event.dateTime.day,
    );

    await _db
        .collection('users')
        .doc(_uid)
        .collection('streaks')
        .doc('streaks')
        .set({
      'eventsCompletedDates': FieldValue.arrayUnion([completedDate]),
    }, SetOptions(merge: true));
  }

  static Future<void> deleteEvent(EventModel event) async {
    await _eventRef(event.objectId).delete();

    await NotificationService.cancelNotification(
        event.uniqueNotificationId ?? 0);
  }
}
