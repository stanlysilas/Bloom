// ChangelogModel-URL-android: https://raw.githubusercontent.com/stanlysilas/bloom_data/refs/heads/main/changelogs/android_changelog.json

class ChangelogModel {
  /// A Model Class for managing the Changelog.
  final String version;
  final String title;
  final String date;
  final List<String> highlights;
  final String notes;

  ChangelogModel({
    required this.version,
    required this.title,
    required this.date,
    required this.highlights,
    required this.notes,
  });

  factory ChangelogModel.fromJson(Map<String, dynamic> json) {
    return ChangelogModel(
      version: json['version'],
      title: json['title'],
      date: json['date'],
      highlights: List<String>.from(json['highlights']),
      notes: json['notes'],
    );
  }
}
