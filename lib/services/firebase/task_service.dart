import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bloom/models/task_model.dart';
import 'package:bloom/services/firebase/notification.dart';
import 'package:bloom/services/audio/audio_manager.dart';
import 'package:flutter/foundation.dart';

class TaskService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String get _uid => _auth.currentUser!.uid;

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.now();
  }

  static DocumentReference<Map<String, dynamic>> _taskRef(String taskId) {
    return _db.collection('users').doc(_uid).collection('tasks').doc(taskId);
  }

  static DocumentReference<Map<String, dynamic>> _nodeRef({
    required String taskId,
    required List<String> path,
  }) {
    var ref = _taskRef(taskId);

    for (final id in path) {
      ref = ref.collection('tasks').doc(id);
    }

    return ref;
  }

  static Future<void> toggleNode({
    required TaskModel task,
    required List<String> path,
    required bool isCompleted,
  }) async {
    final ref = _nodeRef(
      taskId: task.objectId,
      path: path,
    );

    await ref.update({
      'isCompleted': isCompleted,
    });

    if (!isCompleted) {
      return;
    }

    await _completeAllSubTasksRecursive(
      ref.collection('tasks'),
    );

    if (path.isNotEmpty) {
      return;
    }

    AudioManager().playTaskCompleted();

    if (task.uniqueNotificationId != null) {
      await NotificationService.cancelNotification(
        task.uniqueNotificationId!,
      );

      await _db.collection('users').doc(_uid).update({
        'notificationIds': FieldValue.arrayRemove([
          task.uniqueNotificationId,
        ]),
      });
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

  static Future<void> _completeAllSubTasksRecursive(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    final snapshot = await collection.get();

    for (final doc in snapshot.docs) {
      await doc.reference.update({
        'isCompleted': true,
      });

      await _completeAllSubTasksRecursive(
        doc.reference.collection('tasks'),
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
    final parentRef = _nodeRef(
      taskId: taskId,
      path: parentPath,
    );

    final collection = parentRef.collection('tasks');
    final doc = collection.doc();

    await doc.set({
      'objectId': doc.id,
      'name': name,
      'description': description ?? '',
      'dateTime': dateTime,
      'isCompleted': false,
      'addedOn': DateTime.now(),
      'parentId': parentPath.isEmpty ? taskId : parentPath.last,
      'actionObjectType': 'task',
    });
  }

  static Future<List<TaskModel>> fetchSubTasks({
    required String taskId,
    List<String> parentPath = const [],
  }) async {
    final ref = _nodeRef(
      taskId: taskId,
      path: parentPath,
    );

    final tasksSnapshot = await ref.collection('tasks').get();
    final subTasksSnapshot = await ref.collection('subTasks').get();

    final docs = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};

    for (final doc in tasksSnapshot.docs) {
      docs[doc.id] = doc;
    }

    for (final doc in subTasksSnapshot.docs) {
      docs.putIfAbsent(doc.id, () => doc);
    }

    return docs.values.map((doc) {
      final data = doc.data();

      final normalizedData = {
        ...data,
        'objectId':
            data['objectId'] ?? data['taskId'] ?? data['subTaskId'] ?? doc.id,
        'name': data['name'] ?? data['taskName'] ?? data['subTaskName'] ?? '',
        'description': data['description'] ??
            data['taskNotes'] ??
            data['subTaskNotes'] ??
            '',
        'dateTime':
            data['dateTime'] ?? data['taskDateTime'] ?? data['subTaskDateTime'],
        'isCompleted': data['isCompleted'] ?? false,
        'addedOn': data['addedOn'] ?? DateTime.now(),
        'uniqueNotificationId': data['uniqueNotificationId'] ??
            data['taskUniqueId'] ??
            data['subTaskUniqueId'],
        'groups': data['groups'] ?? data['taskGroups'] ?? [],
        'priorityLevel': data['priorityLevel'] ?? 3,
      };

      return TaskModel.fromFirestore(
        normalizedData,
        [
          ...parentPath,
          doc.id,
        ],
      );
    }).toList();
  }

  static Future<void> deleteNode({
    required TaskModel task,
    required List<String> path,
  }) async {
    final ref = _nodeRef(
      taskId: task.objectId,
      path: path,
    );

    await _deleteNodeRecursive(ref);

    if (path.isNotEmpty || task.uniqueNotificationId == null) {
      return;
    }

    await NotificationService.cancelNotification(
      task.uniqueNotificationId!,
    );

    await _db.collection('users').doc(_uid).update({
      'notificationIds': FieldValue.arrayRemove([
        task.uniqueNotificationId,
      ]),
    });
  }

  static Future<void> _deleteNodeRecursive(
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    final children = await ref.collection('tasks').get();

    for (final child in children.docs) {
      await _deleteNodeRecursive(child.reference);
    }

    await ref.delete();
  }

  static Future<void> deleteTask(TaskModel task) async {
    await deleteNode(
      task: task,
      path: const [],
    );
  }

  static Future<void> toggleTask(
    TaskModel task,
    bool isCompleted,
  ) async {
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
    List<String> parentPath = const [],
  }) async {
    await toggleNode(
      task: task,
      path: [
        ...parentPath,
        subTaskId,
      ],
      isCompleted: isCompleted,
    );
  }
}
