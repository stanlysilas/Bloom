import 'package:async/async.dart';
import 'package:bloom/core/utils/object_factory.dart';
import 'package:bloom/models/bloom_object_model.dart';
import 'package:bloom/models/event_model.dart';
import 'package:bloom/models/habit_model.dart';
import 'package:bloom/models/task_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

class DashboardData {
  final int pendingTasks;
  final int numberOfHabits;
  final int numberOfSchedules;
  final int numberOfEntries;
  final int numberOfEntriesInYear;
  final int completedTasksInYear;
  final int attendedEventsInYear;
  final bool isTaskEmpty;
  final bool isEventEmpty;
  final List<DateTime> dates;
  final double dailyProgressValue;

  DashboardData({
    required this.pendingTasks,
    required this.numberOfHabits,
    required this.numberOfSchedules,
    required this.numberOfEntries,
    required this.numberOfEntriesInYear,
    required this.completedTasksInYear,
    required this.attendedEventsInYear,
    required this.isTaskEmpty,
    required this.isEventEmpty,
    required this.dates,
    required this.dailyProgressValue,
  });
}

class DataService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<DashboardData> dataOverview(DateTime date) async {
    final dayStart = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final dayEnd = DateTime(date.year, date.month, date.day, 23, 59, 59);
    final dateString = DateFormat('yyyy-MM-dd').format(date);

    final baseRef = _db.collection('users').doc(_auth.currentUser?.uid);

    final taskQuery = baseRef
        .collection('tasks')
        .where('isCompleted', isEqualTo: false)
        .where('taskDateTime', isGreaterThanOrEqualTo: dayStart)
        .where('taskDateTime', isLessThanOrEqualTo: dayEnd)
        .get();

    final completedTaskTodayQuery = baseRef
        .collection('tasks')
        .where('isCompleted', isEqualTo: true)
        .where('taskDateTime', isGreaterThanOrEqualTo: dayStart)
        .where('taskDateTime', isLessThanOrEqualTo: dayEnd)
        .count()
        .get();

    final habitQuery = baseRef
        .collection('habits')
        .where('habitDateTime', isGreaterThanOrEqualTo: dayStart)
        .where('habitDateTime', isLessThanOrEqualTo: dayEnd)
        .get();

    final eventQuery = baseRef
        .collection('events')
        .where('isAttended', isEqualTo: false)
        .where('eventStartDateTime', isGreaterThanOrEqualTo: dayStart)
        .where('eventEndDateTime', isLessThanOrEqualTo: dayEnd)
        .get();

    final attendedEventTodayQuery = baseRef
        .collection('events')
        .where('isAttended', isEqualTo: true)
        .where('eventStartDateTime', isGreaterThanOrEqualTo: dayStart)
        .where('eventEndDateTime', isLessThanOrEqualTo: dayEnd)
        .count()
        .get();

    final entryQuery = baseRef
        .collection('entries')
        .where('dateTime', isGreaterThanOrEqualTo: dayStart)
        .where('dateTime', isLessThanOrEqualTo: dayEnd)
        .count()
        .get();

    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear =
        DateTime(now.year + 1, 1, 1).subtract(const Duration(seconds: 1));

    final entriesInYearQuery = baseRef
        .collection('entries')
        .where('dateTime', isGreaterThanOrEqualTo: startOfYear)
        .where('dateTime', isLessThanOrEqualTo: endOfYear)
        .count()
        .get();

    final tasksInYearQuery = baseRef
        .collection('tasks')
        .where('taskDateTime', isGreaterThanOrEqualTo: startOfYear)
        .where('taskDateTime', isLessThanOrEqualTo: endOfYear)
        .where('isCompleted', isEqualTo: true)
        .count()
        .get();

    final eventsInYearQuery = baseRef
        .collection('events')
        .where('eventStartDateTime', isGreaterThanOrEqualTo: startOfYear)
        .where('eventEndDateTime', isLessThanOrEqualTo: endOfYear)
        .where('isAttended', isEqualTo: true)
        .count()
        .get();

    final results = await Future.wait([
      taskQuery,
      habitQuery,
      eventQuery,
      entryQuery,
      entriesInYearQuery,
      tasksInYearQuery,
      eventsInYearQuery,
      completedTaskTodayQuery,
      attendedEventTodayQuery,
    ]);

    final taskSnapshot = results[0] as QuerySnapshot;
    final habitSnapshot = results[1] as QuerySnapshot;
    final eventSnapshot = results[2] as QuerySnapshot;

    final entryCount = (results[3] as AggregateQuerySnapshot).count;
    final yearEntriesCount = (results[4] as AggregateQuerySnapshot).count;
    final yearTasksCount = (results[5] as AggregateQuerySnapshot).count;
    final yearEventsCount = (results[6] as AggregateQuerySnapshot).count;
    final todayCompletedTasksCount =
        (results[7] as AggregateQuerySnapshot).count;
    final todayAttendedEventsCount =
        (results[8] as AggregateQuerySnapshot).count;

    int completedHabitsToday = 0;
    for (var doc in habitSnapshot.docs) {
      final completedDates = doc['completedDates'] ?? [];
      if (completedDates.contains(dateString)) {
        completedHabitsToday++;
      }
    }

    final taskDateTimes = taskSnapshot.docs
        .map((doc) => (doc['taskDateTime'] as Timestamp).toDate())
        .toList();

    final eventDateTimes = eventSnapshot.docs
        .map((doc) => (doc['eventEndDateTime'] as Timestamp).toDate())
        .toList();

    final habitLength = habitSnapshot.docs.length;

    final dates = [...taskDateTimes, ...eventDateTimes]..sort();

    final totalPlanned = taskSnapshot.size +
        todayCompletedTasksCount! +
        eventSnapshot.size +
        todayAttendedEventsCount! +
        habitLength;

    final dailyProgressValue = totalPlanned > 0
        ? (todayCompletedTasksCount +
                todayAttendedEventsCount +
                completedHabitsToday) /
            totalPlanned
        : 0.0;

    return DashboardData(
      pendingTasks: taskSnapshot.size,
      numberOfHabits: habitLength,
      numberOfSchedules: eventSnapshot.size,
      numberOfEntries: entryCount!,
      numberOfEntriesInYear: yearEntriesCount!,
      completedTasksInYear: yearTasksCount!,
      attendedEventsInYear: yearEventsCount!,
      isTaskEmpty: taskSnapshot.size == 0,
      isEventEmpty: eventSnapshot.size == 0,
      dates: dates,
      dailyProgressValue: dailyProgressValue,
    );
  }

  Stream<DashboardData> dashboardStream(DateTime date) {
    final uid = _auth.currentUser!.uid;

    final dayStart = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final dayEnd = DateTime(date.year, date.month, date.day, 23, 59, 59);
    final dateString = DateFormat('yyyy-MM-dd').format(date);

    final baseRef = _db.collection('users').doc(uid);

    final tasksStream = baseRef.collection('tasks').snapshots();
    final habitsStream = baseRef.collection('habits').snapshots();
    final eventsStream = baseRef.collection('events').snapshots();
    final entriesStream = baseRef.collection('entries').snapshots();
    final objectsStream = baseRef.collection('objects').snapshots();

    return StreamZip([
      tasksStream,
      habitsStream,
      eventsStream,
      entriesStream,
      objectsStream,
    ]).map((streams) {
      final taskDocs = streams[0].docs;
      final habitDocs = streams[1].docs;
      final eventDocs = streams[2].docs;
      final entryDocs = streams[3].docs;
      final objectDocs = streams[4].docs;

      int pendingTasks = 0;
      int todayCompletedTasks = 0;
      int completedTasksInYear = 0;

      for (var doc in taskDocs) {
        final data = doc.data();
        final isCompleted = data['isCompleted'] ?? false;
        final dateTime =
            (data['taskDateTime'] ?? data['dateTime'] as Timestamp?)?.toDate();

        if (dateTime == null) continue;

        if (!isCompleted &&
            dateTime.isAfter(dayStart) &&
            dateTime.isBefore(dayEnd)) {
          pendingTasks++;
        }

        if (isCompleted &&
            dateTime.isAfter(dayStart) &&
            dateTime.isBefore(dayEnd)) {
          todayCompletedTasks++;
        }

        if (isCompleted && dateTime.year == date.year) {
          completedTasksInYear++;
        }
      }

      int numberOfSchedules = 0;
      int todayAttendedEvents = 0;

      for (var doc in eventDocs) {
        final data = doc.data();

        final start =
            (data['eventStartDateTime'] ?? data['dateTime'] as Timestamp?)
                ?.toDate();
        final end =
            (data['eventEndDateTime'] ?? data['endDateTime'] as Timestamp?)
                ?.toDate();

        if (start == null || end == null) continue;

        final overlapsToday = !start.isAfter(dayEnd) && !end.isBefore(dayStart);

        if (overlapsToday) {
          numberOfSchedules++;

          if (data['isAttended'] == true) {
            todayAttendedEvents++;
          }
        }
      }

      int numberOfHabits = 0;
      int completedHabitsToday = 0;

      for (var doc in habitDocs) {
        final data = doc.data();

        final habitDate =
            (data['habitDateTime'] ?? data['dateTime'] as Timestamp?)?.toDate();

        if (habitDate == null) continue;

        if (habitDate.isAfter(dayStart) && habitDate.isBefore(dayEnd)) {
          numberOfHabits++;

          final completedDates = data['completedDates'] ?? [];
          if (completedDates.contains(dateString)) {
            completedHabitsToday++;
          }
        }
      }

      final habitLength = habitDocs.length;

      int numberOfEntries = 0;

      for (var doc in [...entryDocs, ...objectDocs]) {
        final data = doc.data();

        final dateTime = (data['dateTime'] as Timestamp?)?.toDate();

        if (dateTime == null) continue;

        if (dateTime.isAfter(dayStart) && dateTime.isBefore(dayEnd)) {
          numberOfEntries++;
        }
      }

      final totalPlanned = pendingTasks +
          todayCompletedTasks +
          numberOfSchedules +
          todayAttendedEvents +
          habitLength;

      final dailyProgressValue = totalPlanned > 0
          ? (todayCompletedTasks + todayAttendedEvents + completedHabitsToday) /
              totalPlanned
          : 0.0;

      return DashboardData(
        pendingTasks: pendingTasks,
        numberOfHabits: numberOfHabits,
        numberOfSchedules: numberOfSchedules,
        numberOfEntries: numberOfEntries,
        numberOfEntriesInYear: numberOfEntries,
        completedTasksInYear: completedTasksInYear,
        attendedEventsInYear: todayAttendedEvents,
        isTaskEmpty: pendingTasks == 0,
        isEventEmpty: numberOfSchedules == 0,
        dates: [],
        dailyProgressValue: dailyProgressValue,
      );
    });
  }

  Stream<List<BloomObjectModel>> dashboardObjectsStream(DateTime date) {
    final uid = _auth.currentUser!.uid;

    final dayStart = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final dayEnd = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final baseRef = _db.collection('users').doc(uid);

    final tasksStream = baseRef.collection('tasks').snapshots();

    final entriesStream = baseRef
        .collection('entries')
        .where('dateTime', isGreaterThanOrEqualTo: dayStart)
        .where('dateTime', isLessThanOrEqualTo: dayEnd)
        .snapshots();

    final objectsStream = baseRef
        .collection('objects')
        .where('dateTime', isGreaterThanOrEqualTo: dayStart)
        .where('dateTime', isLessThanOrEqualTo: dayEnd)
        .snapshots();

    final habitsStream = baseRef.collection('habits').snapshots();

    final eventsStream = baseRef.collection('events').snapshots();

    return Rx.combineLatest5(
      tasksStream,
      habitsStream,
      eventsStream,
      entriesStream,
      objectsStream,
      (tasksSnap, habitsSnap, eventsSnap, entriesSnap, objectsSnap) {
        final List<BloomObjectModel> all = [];

        for (var doc in tasksSnap.docs) {
          final data = doc.data();
          data['objectId'] = doc.id;

          final rawDate = data['dateTime'] ?? data['taskDateTime'];

          if (rawDate == null) continue;

          final DateTime dateTime =
              (rawDate is Timestamp) ? rawDate.toDate() : rawDate;

          if (dateTime.isAfter(dayStart) && dateTime.isBefore(dayEnd)) {
            all.add(TaskModel.fromFirestore(data, []));
          }
        }

        for (var doc in habitsSnap.docs) {
          final data = doc.data();
          data['objectId'] = doc.id;

          final model = HabitModel.fromFirestore(data);

          if (model.dateTime.isAfter(dayStart) &&
              model.dateTime.isBefore(dayEnd)) {
            all.add(model);
          }
        }

        for (var doc in eventsSnap.docs) {
          final data = doc.data();
          data['objectId'] = doc.id;

          final model = EventModel.fromFirestore(data);

          final start = model.dateTime;
          final end = model.endDateTime ?? model.dateTime;

          final overlaps = !start.isAfter(dayEnd) && !end.isBefore(dayStart);

          if (overlaps) {
            all.add(model);
          }
        }

        for (var doc in [...entriesSnap.docs, ...objectsSnap.docs]) {
          final data = doc.data();
          data['objectId'] = doc.id;
          all.add(ObjectFactory.fromFirestore(data));
        }

        all.sort((a, b) => b.dateTime.compareTo(a.dateTime));

        return all;
      },
    );
  }
}
