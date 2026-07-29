import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bloom/models/habit_model.dart';

class HabitService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String get _uid => _auth.currentUser!.uid;

  static DocumentReference<Map<String, dynamic>> _habitRef(String id) {
    return _db.collection('users').doc(_uid).collection('habits').doc(id);
  }

  static Future<void> toggleToday(HabitModel habit) async {
    final ref = _habitRef(habit.objectId);

    final now = DateTime.now();
    final todayKey = _format(now);
    final yesterdayKey = _format(now.subtract(const Duration(days: 1)));

    final completedDates = List<String>.from(habit.completedDates);

    final alreadyCompleted = completedDates.contains(todayKey);

    int currentStreak = habit.currentStreak;
    int bestStreak = habit.bestStreak;

    if (alreadyCompleted) {
      completedDates.remove(todayKey);
      currentStreak = currentStreak > 0 ? currentStreak - 1 : 0;
    } else {
      completedDates.add(todayKey);

      final completedYesterday = completedDates.contains(yesterdayKey);

      currentStreak = completedYesterday ? currentStreak + 1 : 1;

      if (currentStreak > bestStreak) {
        bestStreak = currentStreak;
      }
    }

    await ref.update({
      'completedDates': completedDates,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'lastUpdated': todayKey,
    });
  }

  static Future<void> deleteHabit(HabitModel habit) async {
    await _habitRef(habit.objectId).delete();
  }

  static String _format(DateTime d) {
    return "${d.year}-${_two(d.month)}-${_two(d.day)}";
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}
