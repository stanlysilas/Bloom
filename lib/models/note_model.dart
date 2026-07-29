import 'package:bloom/models/bloom_object_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel extends BloomObjectModel {
  NoteModel({
    super.parentId,
    super.parentType,
    required super.title,
    required super.content,
    required super.icon,
    required super.addedOn,
    required super.dateTime,
    required super.isFavorite,
    required super.isLocked,
    required super.backgroundImageUrl,
    required super.attachments,
    required super.children,
    required super.hasChildren,
    required super.type,
    required super.isSyncing,
    required super.objectId,
  }) : super(bloomObjectType: BloomObjectType.note);

  factory NoteModel.fromFirestore(Map<String, dynamic> data) {
    final Timestamp? addedOnTimestamp = data['addedOn'] ?? data['createdAt'];
    final Timestamp? dateTimeTimestamp = data['dateTime'] ?? data['updatedAt'];

    return NoteModel(
      parentId: data['parentId'] ?? data['bookId'] ?? data['id'],
      parentType: data['parentType'] != null
          ? BloomObjectType.values.firstWhere(
              (e) => e.name == data['parentType'],
            )
          : null,
      objectId: data['objectId'] ??
          data['pageId'] ??
          data['entryId'] ??
          data['mainEntryId'],
      type: data['objectType'] ??
          data['mainEntryType'] ??
          data['pageType'] ??
          'note',
      title: data['title'] ?? data['mainEntryTitle'] ?? data['pageTitle'] ?? '',
      content: data['content'] ??
          data['mainEntryDescription'] ??
          data['pageDescription'] ??
          '',
      icon: data['icon'] ?? data['mainEntryEmoji'] ?? data['pageEmoji'] ?? '',
      addedOn: addedOnTimestamp?.toDate() ?? DateTime.now(),
      dateTime: dateTimeTimestamp?.toDate() ?? DateTime.now(),
      isFavorite: data['isFavorite'] ?? false,
      isLocked: data['isLocked'] ?? data['isEntryLocked'] ?? false,
      backgroundImageUrl: data['backgroundImageUrl'] ?? '',
      attachments: data['attachments'] ?? [],
      children: data['children'] ?? [],
      hasChildren: data['hasChildren'] ?? false,
      isSyncing: data.isNotEmpty,
    );
  }

  factory NoteModel.create({
    required String? parentId,
    BloomObjectType? parentType,
    required String objectId,
  }) {
    final now = DateTime.now();

    return NoteModel(
      parentId: parentId,
      parentType: parentType,
      objectId: objectId,
      type: '',
      title: '',
      content: '',
      icon: '',
      addedOn: now,
      dateTime: now,
      isFavorite: false,
      isLocked: false,
      backgroundImageUrl: '',
      attachments: const [],
      children: const [],
      hasChildren: false,
      isSyncing: false,
    );
  }

  @override
  NoteModel copyWith({
    String? parentId,
    BloomObjectType? parentType,
    String? objectId,
    String? type,
    String? title,
    String? content,
    String? icon,
    DateTime? addedOn,
    DateTime? dateTime,
    bool? isFavorite,
    bool? isLocked,
    String? backgroundImageUrl,
    List<dynamic>? attachments,
    List<dynamic>? children,
    bool? hasChildren,
    bool? isSyncing,
    bool? isCompleted,
    DateTime? endDateTime,
    int? priorityLevel,
    List<String>? groups,
  }) {
    return NoteModel(
      parentId: parentId ?? this.parentId,
      parentType: parentType ?? this.parentType,
      objectId: objectId ?? this.objectId,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      icon: icon ?? this.icon,
      addedOn: addedOn ?? this.addedOn,
      dateTime: dateTime ?? this.dateTime,
      isFavorite: isFavorite ?? this.isFavorite,
      isLocked: isLocked ?? this.isLocked,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
      attachments: attachments ?? this.attachments,
      children: children ?? this.children,
      hasChildren: hasChildren ?? this.hasChildren,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      'objectId': objectId,
      'objectType': bloomObjectType.name,
      'parentId': parentId,
      'parentType': parentType?.name,
      'type': type,
      'title': title,
      'content': content,
      'icon': icon,
      'addedOn': addedOn,
      'dateTime': dateTime,
      'isFavorite': isFavorite,
      'isLocked': isLocked,
      'backgroundImageUrl': backgroundImageUrl,
      'attachments': attachments,
      'children': children,
      'hasChildren': hasChildren,
    };
  }
}
