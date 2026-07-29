// ignore_for_file: use_super_parameters

import 'package:bloom/models/action_object_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HabitModel extends ActionObjectModel {
  final List<String> completedDates;
  final int bestStreak;
  final int currentStreak;
  final List<int> daysOfWeek;
  final String? lastUpdated;

  HabitModel({
    required String objectId,
    required DateTime addedOn,
    required String name,
    String? description,
    required bool isCompleted,
    required DateTime dateTime,
    DateTime? endDateTime,
    int? uniqueNotificationId,
    List<String>? groups,
    this.completedDates = const [],
    this.bestStreak = 0,
    this.currentStreak = 0,
    this.daysOfWeek = const [],
    this.lastUpdated = '',
  }) : super(
          actionObjectType: ActionObjectType.habit,
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

  factory HabitModel.fromFirestore(Map<String, dynamic> data) {
    return HabitModel(
      objectId: data['habitId'] ?? data['objectId'],
      addedOn: _parseDate(data['addedOn']),
      name: data['habitName'] ?? data['name'] ?? '',
      description: data['habitNotes'] ?? data['description'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      dateTime: _parseDate(data['habitDateTime'] ?? data['dateTime']),
      endDateTime: _parseNullableDate(data['endDateTime']),
      uniqueNotificationId:
          data['habitUniqueId'] ?? data['uniqueNotificationId'],
      groups:
          ((data['habitGroups'] ?? data['groups']) as List?)?.cast<String>(),
      completedDates: (data['completedDates'] as List?)?.cast<String>() ?? [],
      bestStreak: data['bestStreak'] ?? 0,
      currentStreak: data['currentStreak'] ?? 0,
      daysOfWeek: (data['daysOfWeek'] as List?)?.cast<int>() ?? const [],
      lastUpdated: data['lastUpdated'] ?? '',
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
      'completedDates': completedDates,
      'bestStreak': bestStreak,
      'currentStreak': currentStreak,
      'daysOfWeek': daysOfWeek,
      'lastUpdated': lastUpdated ?? '',
    };
  }

  @override
  HabitModel copyWith({
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
    List<String>? completedDates,
    int? bestStreak,
    int? currentStreak,
    List<int>? daysOfWeek,
    String? lastUpdated,
  }) {
    return HabitModel(
      objectId: objectId,
      addedOn: addedOn,
      name: title ?? name,
      description: content ?? description,
      isCompleted: isCompleted ?? this.isCompleted,
      dateTime: dateTime ?? this.dateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      uniqueNotificationId: uniqueNotificationId,
      groups: groups ?? this.groups,
      completedDates: completedDates ?? this.completedDates,
      bestStreak: bestStreak ?? this.bestStreak,
      currentStreak: currentStreak ?? this.currentStreak,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      lastUpdated: lastUpdated ?? this.lastUpdated,
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
}
