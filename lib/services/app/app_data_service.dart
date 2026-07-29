import 'package:bloom/models/app_data_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppDataService {
  final _db = FirebaseFirestore.instance;

  Future<AppDataModel?> fetchAppData() async {
    final doc = await _db.collection('appData').doc('appData').get();

    if (!doc.exists) return null;

    final appData = doc.data()!;

    return AppDataModel.fromFirestore(appData);
  }
}
