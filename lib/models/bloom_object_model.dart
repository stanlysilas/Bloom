enum BloomObjectType {
  note,
  book,
  bookPage,
  checklist,
  drawing,
  actionObject,
}

abstract class BloomObjectModel {
  String? parentId;
  final BloomObjectType? parentType;
  final String type;
  final BloomObjectType bloomObjectType;
  final String title;
  final String content;
  final String icon;
  final DateTime addedOn;
  final DateTime dateTime;
  final bool isFavorite;
  final bool isLocked;
  bool isSyncing;
  final String backgroundImageUrl;
  final List attachments;
  final List children;
  final bool hasChildren;
  String? objectId;

  BloomObjectModel({
    this.parentId,
    this.parentType,
    required this.type,
    required this.bloomObjectType,
    required this.title,
    required this.content,
    required this.icon,
    required this.addedOn,
    required this.dateTime,
    required this.isFavorite,
    required this.isLocked,
    required this.isSyncing,
    this.objectId,
    required this.backgroundImageUrl,
    required this.attachments,
    required this.children,
    required this.hasChildren,
  });

  Map<String, dynamic> toFirestore();

  BloomObjectModel copyWith({
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
  });
}
