// ignore_for_file: use_super_parameters

import 'package:bloom/models/action_object_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventModel extends ActionObjectModel {
  final String location;
  final String eventColorCode;
  final Color color;

  EventModel({
    required String objectId,
    required DateTime addedOn,
    required String name,
    String? description,
    required bool isCompleted,
    required DateTime dateTime,
    DateTime? endDateTime,
    int? uniqueNotificationId,
    List<String>? groups,
    this.location = '',
    this.eventColorCode = 'FF5E7CE2',
  })  : color = _parseColor(eventColorCode),
        super(
          actionObjectType: ActionObjectType.event,
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

  factory EventModel.fromFirestore(Map<String, dynamic> data) {
    final colorCode = data['eventColorCode'] ?? data['colorCode'] ?? 'FF5E7CE2';

    return EventModel(
      objectId: data['eventId'] ?? data['objectId'],
      addedOn: _parseDate(data['addedOn'] ?? data['eventStartDateTime']),
      name: data['eventName'] ?? data['name'] ?? '',
      description: data['eventNotes'] ?? data['description'] ?? '',
      isCompleted: data['isAttended'] ?? data['isCompleted'] ?? false,
      dateTime: _parseDate(data['eventStartDateTime'] ?? data['dateTime']),
      endDateTime:
          _parseNullableDate(data['eventEndDateTime'] ?? data['endDateTime']),
      uniqueNotificationId:
          data['eventUniqueId'] ?? data['uniqueNotificationId'] ?? 0,
      eventColorCode: colorCode,
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
      'colorCode': eventColorCode,
    };
  }

  @override
  EventModel copyWith({
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
    String? location,
    String? eventColorCode,
  }) {
    final newColorCode = eventColorCode ?? this.eventColorCode;

    return EventModel(
      objectId: objectId,
      addedOn: addedOn,
      name: title ?? name,
      description: content ?? description,
      isCompleted: isCompleted ?? this.isCompleted,
      dateTime: dateTime ?? this.dateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      uniqueNotificationId: uniqueNotificationId,
      groups: groups ?? this.groups,
      location: location ?? this.location,
      eventColorCode: newColorCode,
    );
  }

  static Color _parseColor(String hex) {
    final cleaned = hex.replaceAll('#', '');

    if (cleaned.length == 6) {
      return Color(int.parse('FF$cleaned', radix: 16));
    } else if (cleaned.length == 8) {
      return Color(int.parse(cleaned, radix: 16));
    }

    return const Color(0xFF5E7CE2);
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
