class AppDataModel {
  final int buildNumberAndroid;
  final int? minimumBuildNumberAndroid;
  final String latestAndroidVersion;
  final String status;

  const AppDataModel({
    required this.buildNumberAndroid,
    this.minimumBuildNumberAndroid,
    required this.latestAndroidVersion,
    required this.status,
  });

  factory AppDataModel.fromFirestore(Map<String, dynamic> doc) {
    return AppDataModel(
        buildNumberAndroid: doc['buildNumberAndroid'],
        minimumBuildNumberAndroid: doc['minimumBuildNumberAndroid'] ?? 23,
        latestAndroidVersion: doc['latestAndroidVersion'],
        status: doc['status']);
  }
}
