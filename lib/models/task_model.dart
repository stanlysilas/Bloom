// ignore_for_file: use_super_parameters

import 'package:bloom/models/action_object_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel extends ActionObjectModel {
  final int? priorityLevel;
  final String? priorityLevelString;
  final List<String> parentPath;

  TaskModel({
    required String objectId,
    required DateTime addedOn,
    required String name,
    String? description,
    required bool isCompleted,
    required DateTime dateTime,
    DateTime? endDateTime,
    int? uniqueNotificationId,
    List<String>? groups,
    this.priorityLevel = 3,
    this.priorityLevelString = 'Low',
    this.parentPath = const [],
  }) : super(
          actionObjectType: ActionObjectType.task,
          objectId: objectId,
          addedOn: addedOn,
          name: name,
          description: description,
          isCompleted: isCompleted,
          uniqueNotificationId: uniqueNotificationId,
          dateTime: dateTime,
          endDateTime: endDateTime,
          groups: groups,
        );

  factory TaskModel.fromFirestore(Map<String, dynamic> data, List<String>? parentPath) {
    final priority = data['priorityLevel'] ?? 3;

    return TaskModel(
      objectId: data['taskId'] ?? data['objectId'],
      addedOn: _parseDate(data['addedOn']),
      name: data['taskName'] ?? data['name'] ?? '',
      description: data['taskNotes'] ?? data['description'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      dateTime: _parseDate(data['taskDateTime'] ?? data['dateTime']),
      endDateTime: _parseNullableDate(data['endDateTime']),
      uniqueNotificationId:
          data['taskUniqueId'] ?? data['uniqueNotificationId'],
      groups: ((data['taskGroups'] ?? data['groups']) as List?)?.cast<String>(),
      priorityLevel: priority,
      priorityLevelString: _resolvePriorityLevel(priority),
      parentPath: parentPath ?? const [],
    );
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      'objectId': objectId,
      'addedOn': addedOn,
      'name': name,
      'description': description ?? '',
      'isCompleted': isCompleted,
      'dateTime': dateTime,
      'endDateTime': endDateTime,
      'uniqueNotificationId': uniqueNotificationId ?? 0,
      'groups': groups ?? const [],
      'priorityLevel': priorityLevel ?? 3,
      'priorityLevelString': _resolvePriorityLevel(priorityLevel ?? 3),
    };
  }

  @override
  TaskModel copyWith({
    String? title,
    String? content,
    String? icon,
    bool? isFavorite,
    bool? isLocked,
    bool? isSyncing,
    String? backgroundImageUrl,
    DateTime? dateTime,
    bool? isCompleted,
    DateTime? endDateTime,
    int? priorityLevel,
    List<String>? groups,
  }) {
    final newPriority = priorityLevel ?? this.priorityLevel ?? 3;

    return TaskModel(
      objectId: objectId,
      addedOn: addedOn,
      name: title ?? name,
      description: content ?? description,
      isCompleted: isCompleted ?? this.isCompleted,
      dateTime: dateTime ?? this.dateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      uniqueNotificationId: uniqueNotificationId,
      groups: groups ?? this.groups,
      priorityLevel: newPriority,
      priorityLevelString: _resolvePriorityLevel(newPriority),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    return DateTime.now();
  }

  static DateTime? _parseNullableDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  static String _resolvePriorityLevel(int value) {
    switch (value) {
      case 1:
        return 'High';
      case 2:
        return 'Medium';
      case 3:
        return 'Low';
      default:
        return 'Low';
    }
  }
}
