import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bloom/models/task_model.dart';
import 'package:bloom/services/firebase/notification.dart';
import 'package:bloom/services/audio/audio_manager.dart';

class TaskService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String get _uid => _auth.currentUser!.uid;

  static DocumentReference<Map<String, dynamic>> _taskRef(String taskId) {
    return _db.collection('users').doc(_uid).collection('tasks').doc(taskId);
  }

  static DocumentReference<Map<String, dynamic>> _nodeRef({
    required String taskId,
    required List<String> path,
  }) {
    var ref = _taskRef(taskId);

    for (final id in path) {
      ref = ref.collection('subTasks').doc(id);
    }

    return ref;
  }

  static Future<void> toggleNode({
    required TaskModel task,
    required List<String> path,
    required bool isCompleted,
  }) async {
    final ref = _nodeRef(taskId: task.objectId, path: path);

    await ref.update({'isCompleted': isCompleted});

    if (isCompleted) {
      await _completeAllSubTasksRecursive(
        ref.collection('subTasks'),
      );

      if (path.isEmpty) {
        AudioManager().playTaskCompleted();

        if (task.uniqueNotificationId != null) {
          NotificationService.cancelNotification(
            task.uniqueNotificationId!,
          );
        }

        final date = DateTime(
          task.dateTime.year,
          task.dateTime.month,
          task.dateTime.day,
        );

        await _db
            .collection('users')
            .doc(_uid)
            .collection('streaks')
            .doc('streaks')
            .set({
          'tasksCompletedDates': FieldValue.arrayUnion([date]),
        }, SetOptions(merge: true));
      }
    }
  }

  static Future<void> _completeAllSubTasksRecursive(
    CollectionReference<Map<String, dynamic>> ref,
  ) async {
    final snapshot = await ref.get();

    for (final doc in snapshot.docs) {
      await doc.reference.update({'isCompleted': true});

      await _completeAllSubTasksRecursive(
        doc.reference.collection('subTasks'),
      );
    }
  }

  static Future<void> addSubTask({
    required String taskId,
    required String name,
    String? description,
    required DateTime dateTime,
    List<String> parentPath = const [],
  }) async {
    final parentRef = _nodeRef(taskId: taskId, path: parentPath);

    final collection = parentRef.collection('subTasks');
    final doc = collection.doc();

    await doc.set({
      'objectId': doc.id,
      'name': name,
      'description': description ?? '',
      'dateTime': dateTime,
      'isCompleted': false,
      'addedOn': DateTime.now(),
    });
  }

  static Future<void> deleteNode({
    required TaskModel task,
    required List<String> path,
  }) async {
    final ref = _nodeRef(taskId: task.objectId, path: path);

    await ref.delete();

    if (path.isEmpty && task.uniqueNotificationId != null) {
      NotificationService.cancelNotification(
        task.uniqueNotificationId!,
      );

      await _db.collection('users').doc(_uid).update({
        'notificationIds': FieldValue.arrayRemove([task.uniqueNotificationId])
      });
    }
  }

  static Future<void> deleteTask(TaskModel task) async {
    final ref = _taskRef(task.objectId);

    await ref.delete();

    if (task.uniqueNotificationId != null) {
      NotificationService.cancelNotification(
        task.uniqueNotificationId!,
      );

      await _db.collection('users').doc(_uid).update({
        'notificationIds': FieldValue.arrayRemove([task.uniqueNotificationId])
      });
    }
  }

  static Future<void> toggleTask(TaskModel task, bool isCompleted) async {
    await toggleNode(
      task: task,
      path: const [],
      isCompleted: isCompleted,
    );
  }

  static Future<void> toggleSubTask({
    required TaskModel task,
    required String subTaskId,
    required bool isCompleted,
  }) async {
    await toggleNode(
      task: task,
      path: [subTaskId],
      isCompleted: isCompleted,
    );
  }
}
