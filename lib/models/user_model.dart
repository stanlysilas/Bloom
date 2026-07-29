class UserModel {
  final String uid;
  final String email;
  final String profilePicture;
  final String userName;
  final String? fcmToken;
  final bool isEmailAndPassword;
  final bool isImageNetwork;
  final String entriesColorCode;
  final String eventsColorCode;
  final String habitsColorCode;
  final String tasksColorCode;
  final List? notificationIds;

  const UserModel(
      {required this.uid,
      required this.email,
      required this.profilePicture,
      required this.userName,
      this.fcmToken,
      required this.isEmailAndPassword,
      required this.isImageNetwork,
      required this.entriesColorCode,
      required this.eventsColorCode,
      required this.habitsColorCode,
      required this.tasksColorCode,
      this.notificationIds});

  factory UserModel.fromFirestore(String uid, Map<String, dynamic> doc) {
    return UserModel(
      uid: uid,
      email: doc['email'],
      profilePicture: doc['profilePicture'],
      userName: doc['userName'],
      fcmToken: doc['fcmToken'] ?? '',
      isEmailAndPassword: doc['isEmailAndPassword'],
      isImageNetwork: doc['isImageNetwork'],
      entriesColorCode: doc['entriesColorCode'],
      eventsColorCode: doc['eventsColorCode'],
      habitsColorCode: doc['habitsColorCode'],
      tasksColorCode: doc['tasksColorCode'],
      notificationIds: doc['notificationIds'] ?? [],
    );
  }
}
