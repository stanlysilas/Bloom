import 'package:bloom/models/bloom_object_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookModel extends BloomObjectModel {
  final List<String> tags;
  final bool isTemplate;

  BookModel({
    required super.objectId,
    super.parentId,
    super.parentType,
    required super.type,
    required super.title,
    required super.content,
    required super.icon,
    required super.addedOn,
    required super.dateTime,
    required super.children,
    required super.attachments,
    required super.hasChildren,
    required super.isFavorite,
    required super.isLocked,
    required super.isSyncing,
    required super.backgroundImageUrl,
    this.tags = const [],
    this.isTemplate = false,
  }) : super(bloomObjectType: BloomObjectType.book);

  factory BookModel.fromFirestore(
    Map<String, dynamic> map, {
    String? fallbackBookId,
    String? docId,
  }) {
    return BookModel(
      objectId: map['objectId'] ?? map['bookId'] ?? docId,
      parentId: map['parentId'] ?? fallbackBookId,
      parentType: map['parentType'] != null
          ? BloomObjectType.values.firstWhere(
              (e) => e.name == map['parentType'],
            )
          : null,
      type: map['objectType'] ?? map['type'] ?? 'book',
      title: map['title'] ?? map['bookTitle'] ?? 'Book',
      content: map['content'] ??
          map['description'] ??
          map['bookDescription'] ??
          "This is a Book entry type.",
      icon: map['icon'] ?? map['bookEmoji'] ?? '📓',
      addedOn: _parseDateTime(map['addedOn']) ?? DateTime.now(),
      dateTime: _parseDateTime(map['dateTime']) ?? DateTime.now(),
      children: (map['children'] as List?) ?? const [],
      attachments: (map['attachments'] as List?) ?? const [],
      tags: ((map['tags'] as List?) ?? const []).cast<String>(),
      hasChildren: map['hasChildren'] ?? false,
      isFavorite: map['isFavorite'] ?? false,
      isLocked: map['isLocked'] ?? map['isBookLocked'] ?? false,
      backgroundImageUrl: map['backgroundImageUrl'] ?? '',
      isSyncing: true,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      'objectId': objectId,
      'objectType': bloomObjectType.name,
      'parentId': parentId,
      'parentType': parentType?.name,
      'title': title,
      'content': content,
      'icon': icon,
      'addedOn': addedOn,
      'dateTime': dateTime,
      'children': children,
      'attachments': attachments,
      'tags': tags,
      'hasChildren': hasChildren,
      'isFavorite': isFavorite,
      'isLocked': isLocked,
      'backgroundImageUrl': backgroundImageUrl,
    };
  }

  @override
  BookModel copyWith({
    String? objectId,
    String? parentId,
    BloomObjectType? parentType,
    String? title,
    String? content,
    String? icon,
    List? children,
    List? attachments,
    bool? hasChildren,
    bool? isFavorite,
    bool? isLocked,
    bool? isSyncing,
    DateTime? addedOn,
    DateTime? dateTime,
    String? backgroundImageUrl,
    List<String>? tags,
    bool? isCompleted,
    DateTime? endDateTime,
    int? priorityLevel,
    List<String>? groups,
  }) {
    return BookModel(
      objectId: objectId ?? this.objectId,
      parentId: parentId ?? this.parentId,
      parentType: parentType ?? this.parentType,
      type: type,
      title: title ?? this.title,
      content: content ?? this.content,
      icon: icon ?? this.icon,
      addedOn: addedOn ?? this.addedOn,
      dateTime: dateTime ?? DateTime.now(),
      children: children ?? this.children,
      attachments: attachments ?? this.attachments,
      hasChildren: hasChildren ?? this.hasChildren,
      isFavorite: isFavorite ?? this.isFavorite,
      isLocked: isLocked ?? this.isLocked,
      isSyncing: isSyncing ?? this.isSyncing,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
      tags: tags ?? this.tags,
    );
  }
}
