import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateService {
  final _db = FirebaseFirestore.instance;

  Future<bool?> updateAvailable() async {
    final prefs = await SharedPreferences.getInstance();

    final appData = await _db.collection('appData').doc('appData').get();

    if (!appData.exists) return null;

    int buildNumberAndroid = appData.data()?['buildNumberAndroid'];
    String latestAndroidVersion = appData.data()?['latestAndroidVersion'];

    final updateCollectionId = "$latestAndroidVersion+$buildNumberAndroid";

    final snapshot = await _db
        .collection('appData')
        .doc('update_dialog')
        .collection(updateCollectionId)
        .get();

    final seenIds = prefs.getStringList('seenUpdateIds') ?? [];
    final hasUnseen =
        snapshot.docs.any((doc) => !seenIds.contains(doc.data()['updateId']));

    if (hasUnseen) {
      return true;
    }

    return false;
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      fetchUnseenUpdatesList(String updateCollectionId) async {
    final prefs = await SharedPreferences.getInstance();
    final seenUpdateIds = prefs.getStringList('seenUpdateIds') ?? [];

    final updateQuery = await _db
        .collection('appData')
        .doc('update_dialog')
        .collection(updateCollectionId)
        .orderBy('date', descending: false)
        .get();

    final filtered = updateQuery.docs.where((doc) {
      final data = doc.data();
      final updateId = data['updateId'] as String?;
      return updateId != null && !seenUpdateIds.contains(updateId);
    }).toList();

    return filtered;
  }

  Future<void> markUpdateAsSeen(String newUpdateId) async {
    final prefs = await SharedPreferences.getInstance();

    final seenUpdateIds = prefs.getStringList('seenUpdateIds') ?? [];

    if (seenUpdateIds.contains(newUpdateId)) return;

    seenUpdateIds.add(newUpdateId);
  }
}
