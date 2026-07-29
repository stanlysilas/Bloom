import 'package:bloom/models/bloom_object_model.dart';

enum ActionObjectType {
  task,
  habit,
  event,
  pomodoro,
}

abstract class ActionObjectModel extends BloomObjectModel {
  final ActionObjectType actionObjectType;
  final String objectId;
  final DateTime addedOn;
  final String name;
  final String? description;
  final bool isCompleted;
  final int? uniqueNotificationId;
  final DateTime dateTime;
  final DateTime? endDateTime;
  final List<String>? groups;

  ActionObjectModel({
    required this.actionObjectType,
    required this.objectId,
    required this.addedOn,
    required this.name,
    this.description = '',
    required this.isCompleted,
    this.uniqueNotificationId = 0,
    required this.dateTime,
    this.endDateTime,
    this.groups,
  }) : super(
          parentId: null,
          parentType: null,
          type: actionObjectType.name,
          bloomObjectType: BloomObjectType.actionObject,
          title: name,
          content: description ?? '',
          icon: _resolveIcon(actionObjectType),
          addedOn: addedOn,
          dateTime: dateTime,
          isFavorite: false,
          isLocked: false,
          isSyncing: false,
          objectId: objectId,
          backgroundImageUrl: '',
          attachments: const [],
          children: const [],
          hasChildren: false,
        );

  static String _resolveIcon(ActionObjectType actionObjectType) {
    switch (actionObjectType) {
      case ActionObjectType.task:
        return '✅';
      case ActionObjectType.habit:
        return '🔁';
      case ActionObjectType.event:
        return '📅';
      case ActionObjectType.pomodoro:
        return '⏳';
    }
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      'actionObjectType': actionObjectType.name,
      'objectId': objectId,
      'type': type,
      'name': name,
      'description': description,
      'isCompleted': isCompleted,
      'uniqueNotificationId': uniqueNotificationId,
      'dateTime': dateTime,
      'endDateTime': endDateTime,
      'addedOn': addedOn,
      'groups': groups,
    };
  }
}
