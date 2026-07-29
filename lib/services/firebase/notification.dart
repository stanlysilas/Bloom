import 'package:bloom/services/firebase/firebase_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static bool get _isSupportedPlatform => !kIsWeb;

  // Generate a unique id for each notification
  int generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }

  // Check firebase for any app updates and send instant notification if yes
  static Future<void> checkForUpdates() async {
    if (!_isSupportedPlatform) return;
    int buildNumberAndroid = 0;
    final info = await PackageInfo.fromPlatform();
    buildNumberAndroid = int.tryParse(info.buildNumber) ?? 0;
    FirebaseFirestore.instance
        .collection('appData')
        .doc('appData')
        .get()
        .then((value) {
      if (value.exists && value['buildNumberAndroid'] > buildNumberAndroid) {
        showInstantNotification(
            'Bloom has an update!',
            'Go to Settings > Info > About app > Download update to download and update Bloom',
            DateTime.now().millisecondsSinceEpoch.remainder(100000));
      }
    });
  }

  // Intitialize the flutter_local_notifications instance
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> onDidReceiveNotification(
      NotificationResponse notificationResponse) async {}

  // Initialise the notifications
  static Future<bool> init() async {
    // Define the Android initialization settings
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/default_app_icon_notification');
    // Define the iOS initialization settings
    const DarwinInitializationSettings iOSInitializationSettings =
        DarwinInitializationSettings();

    // Combine Android and iOS  initialization settings
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iOSInitializationSettings,
    );

    // Initialize the plugin with the specified settings
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotification,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveNotification,
    );

    // Request for permission to show notifications for Android
    final granted = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    if (granted == true) {
      // Get the FCMToken and add it to the user's database
      await FirebaseAPI().initNotifications();
      return true;
    } else if (granted == null) {
      // Get the FCMToken and add it to the user's database
      await FirebaseAPI().initNotifications();
      return false;
    } else {
      // Get the FCMToken and add it to the user's database
      await FirebaseAPI().initNotifications();
      return false;
    }
  }

  // Check the active notificationIds against the ones in Firestore
  // static Future<void> checkNotificationIds() async {
  //   final notificationIds = await FirebaseAPI().getNotificationID();
  //   final pendingRequests =
  //       await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  //   final List<int> pendingNotifications =
  //       pendingRequests.map((request) => request.id).toList();
  //   final notificationIdsSet = notificationIds.toSet();
  //   final pendingNotificationsSet = pendingNotifications.toSet();
  //   final Set<int> idsToCancel =
  //       pendingNotificationsSet.difference(notificationIdsSet);
  //   print("Pending Notifications: $pendingNotifications");
  //   print("IdsToCancel: $idsToCancel");
  //   for (final int id in idsToCancel) {
  //     await flutterLocalNotificationsPlugin.cancel(id);
  //     print("Canceled notification with ID: $id");
  //   }
  //   // FIXME: MAKE THE CODE TO ALSO CHECK THE FIREBASEIDS AND THEN RESCHEDULE A NOTIFICATION WITH THAT ID IF ITS NOT SCHEDULED
  // }

  // Show an instant notification
  static Future<void> showInstantNotification(
      String title, String body, int uniqueId) async {
    if (!_isSupportedPlatform) return;
    // Define notification details
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'instant_notifications_id',
        'Instant notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await flutterLocalNotificationsPlugin.show(
        uniqueId, title, body, platformChannelSpecifics);
  }

  // Show a tasks notification
  static Future<void> scheduleTasksNotification(
      int uniqueId,
      String title,
      String body,
      DateTime scheduledDate,
      Importance importance,
      Priority priority) async {
    if (!_isSupportedPlatform) return;
    // Define notification details
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'tasks_notifications_id',
        'Tasks notifications',
        channelDescription:
            'This category is used to send timely notifications about your Tasks.',
        importance: importance,
        priority: priority,
        playSound: true,
        enableVibration: true,
        silent: false,
      ),
      iOS: const DarwinNotificationDetails(),
    );
    await flutterLocalNotificationsPlugin.zonedSchedule(uniqueId, title, body,
        tz.TZDateTime.from(scheduledDate, tz.local), platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // uiLocalNotificationDateInterpretation:
        //     UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime);
  }

  static Future<void> scheduleWeeklyTaskNotification({
    required int uniqueId,
    required String title,
    required String body,
    required DateTime scheduleDateTime,
    required List<int> daysOfWeek,
    required Importance importance,
    required Priority priority,
  }) async {
    if (!_isSupportedPlatform) return;

    for (int day in daysOfWeek) {
      tz.TZDateTime nextInstance(int targetDay) {
        final now = tz.TZDateTime.now(tz.local);

        tz.TZDateTime scheduled = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          scheduleDateTime.hour,
          scheduleDateTime.minute,
        );

        while (scheduled.weekday != targetDay + 1 || scheduled.isBefore(now)) {
          scheduled = scheduled.add(const Duration(days: 1));
        }

        return scheduled;
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        uniqueId + day,
        title,
        body,
        nextInstance(day),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'tasks_recurring_id',
            'Recurring Tasks',
            importance: importance,
            priority: priority,
            playSound: true,
            enableVibration: true,
          ),
        ),
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  static Future<void> scheduleTaskNotification({
    required int uniqueId,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required Importance importance,
    required Priority priority,
    bool isRecurring = false,
    List<int>? recurringDays,
  }) async {
    if (!_isSupportedPlatform) return;

    if (!isRecurring) {
      await scheduleTasksNotification(
        uniqueId,
        title,
        body,
        scheduledDate,
        importance,
        priority,
      );
      return;
    }

    if (recurringDays == null || recurringDays.isEmpty) return;

    await scheduleWeeklyTaskNotification(
      uniqueId: uniqueId,
      title: title,
      body: body,
      scheduleDateTime: scheduledDate,
      daysOfWeek: recurringDays,
      importance: importance,
      priority: priority,
    );
  }

  // Show a event notification
  static Future<void> scheduleEventsNotification(
      int uniqueId,
      String title,
      String body,
      DateTime scheduledDate,
      Importance importance,
      Priority priority) async {
    if (!_isSupportedPlatform) return;
    // Define notification details
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'events_notifications_id',
        'Events notifications',
        channelDescription:
            'This category is used to send timely notifications about your Events.',
        importance: importance,
        priority: priority,
        playSound: true,
        enableVibration: true,
        silent: false,
      ),
      iOS: const DarwinNotificationDetails(),
    );
    await flutterLocalNotificationsPlugin.zonedSchedule(uniqueId, title, body,
        tz.TZDateTime.from(scheduledDate, tz.local), platformChannelSpecifics,
        // uiLocalNotificationDateInterpretation:
        //     UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dateAndTime);
  }

  // Show a pomodoro notification
  static Future<void> schedulePomodoroNotification(
      int uniqueId,
      String title,
      String body,
      DateTime scheduledDate,
      Importance importance,
      Priority priority) async {
    if (!_isSupportedPlatform) return;
    // Define notification details
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'pomodoro_notifications_id',
        'Pomodoro notifications',
        channelDescription:
            'This category is used to send timely notifications about your scheduled Pomodoro Timers.',
        importance: importance,
        priority: priority,
        playSound: true,
        enableVibration: true,
        silent: false,
      ),
      iOS: const DarwinNotificationDetails(),
    );
    await flutterLocalNotificationsPlugin.zonedSchedule(uniqueId, title, body,
        tz.TZDateTime.from(scheduledDate, tz.local), platformChannelSpecifics,
        // uiLocalNotificationDateInterpretation:
        //     UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dateAndTime);
  }

  // Schedule a recurring notification reminder
  static Future<void> scheduleRecurringNotification(
      int uniqueId,
      String title,
      String body,
      DateTime scheduleDateTime,
      Importance importance,
      Priority priority,
      String repeat) async {
    if (!_isSupportedPlatform) return;
    tz.TZDateTime nextInstanceOfTime() {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime? scheduledDate;
      if (repeat == 'Daily') {
        scheduledDate = tz.TZDateTime(
            tz.local,
            now.year,
            now.month,
            now.day,
            scheduleDateTime.hour,
            scheduleDateTime.minute,
            scheduleDateTime.second);
      }
      if (scheduledDate!.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      return scheduledDate;
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      uniqueId,
      title,
      body,
      nextInstanceOfTime(),
      NotificationDetails(
        android: AndroidNotificationDetails(
            'recurring_notifications_id', 'Recurring Notifications',
            importance: importance, priority: priority),
      ),
      matchDateTimeComponents: DateTimeComponents.time,
      // uiLocalNotificationDateInterpretation:
      //     UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> scheduleRecurringHabitNotification(
    int uniqueId,
    String title,
    String body,
    DateTime scheduleDateTime,
    List<int> daysOfWeek, // List of days as integers [0-6]
    Importance importance,
    Priority priority,
  ) async {
    if (!_isSupportedPlatform) return;
    for (int day in daysOfWeek) {
      tz.TZDateTime nextInstanceOfDay(int targetWeekday) {
        final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
        tz.TZDateTime scheduledDate = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          scheduleDateTime.hour,
          scheduleDateTime.minute,
          scheduleDateTime.second,
        );

        // If the selected day is before today, move to the next occurrence
        while (scheduledDate.weekday != targetWeekday + 1 ||
            scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }
        // print(scheduledDate);
        return scheduledDate;
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        uniqueId + day, // Ensure unique ID per notification
        title,
        body,
        nextInstanceOfDay(day),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'habit_notifications_id',
            'Habits notifications',
            importance: importance,
            priority: priority,
          ),
        ),
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  static Future<void> _rescheduleTask(
    Map<String, dynamic> data,
    int uniqueId,
    String title,
    String body,
    DateTime dateTime,
  ) async {
    debugPrint('Reschedule task running');
    final recurringDaysRaw = data['recurringDays'];
    final List<int>? recurringDays =
        (recurringDaysRaw as List?)?.map((e) => e as int).toList();

    final isRecurring = recurringDays != null && recurringDays.isNotEmpty;

    await scheduleTaskNotification(
      uniqueId: uniqueId,
      title: title,
      body: body,
      scheduledDate: dateTime,
      importance: Importance.high,
      priority: Priority.high,
      isRecurring: isRecurring,
      recurringDays: recurringDays,
    );
  }

  static Future<void> _rescheduleHabit(
    Map<String, dynamic> data,
    int uniqueId,
    String title,
    String body,
    DateTime dateTime,
  ) async {
    debugPrint('Reschedule habit running');
    final daysRaw = data['daysOfWeek'];
    if (daysRaw == null) return;

    final List<int> days = (daysRaw as List).map((e) => e as int).toList();

    await scheduleRecurringHabitNotification(
      uniqueId,
      title,
      body,
      dateTime,
      days,
      Importance.high,
      Priority.high,
    );
  }

  static Future<void> _rescheduleEvent(
    Map<String, dynamic> data,
    int uniqueId,
    String title,
    String body,
    DateTime dateTime,
  ) async {
    debugPrint('Reschedule event running');
    await scheduleEventsNotification(
      uniqueId,
      title,
      body,
      dateTime,
      Importance.high,
      Priority.high,
    );
  }

  static Future<void> resyncActionNotifications() async {
    if (!_isSupportedPlatform) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

    await flutterLocalNotificationsPlugin.cancelAll();

    final tasksSnap = await userRef.collection('tasks').get();
    final habitsSnap = await userRef.collection('habits').get();
    final eventsSnap = await userRef.collection('events').get();

    final allDocs = [
      ...tasksSnap.docs,
      ...habitsSnap.docs,
      ...eventsSnap.docs,
    ];

    for (final doc in allDocs) {
      final data = doc.data();

      final type = data['actionObjectType'] ?? _inferTypeFromData(data);

      final isCompleted = data['isCompleted'] ?? data['isAttended'] ?? false;
      if (isCompleted) continue;

      final uniqueId = data['uniqueNotificationId'] ??
          data['taskUniqueId'] ??
          data['eventUniqueId'] ??
          data['habitUniqueId'];

      if (uniqueId == null) continue;

      final title = data['name'] ??
          data['taskName'] ??
          data['habitName'] ??
          data['eventName'] ??
          '';

      final body = data['description'] ??
          data['taskNotes'] ??
          data['habitNotes'] ??
          data['eventNotes'] ??
          '';

      final rawDate = data['dateTime'] ??
          data['taskDateTime'] ??
          data['habitDateTime'] ??
          data['eventStartDateTime'];

      if (rawDate == null) continue;

      final DateTime dateTime =
          (rawDate is Timestamp) ? rawDate.toDate() : rawDate;

      switch (type) {
        case 'task':
          await _rescheduleTask(data, uniqueId, title, body, dateTime);
          break;

        case 'habit':
          await _rescheduleHabit(data, uniqueId, title, body, dateTime);
          break;

        case 'event':
          await _rescheduleEvent(data, uniqueId, title, body, dateTime);
          break;

        default:
          break;
      }
    }
  }

  // Cancel the notification if the task/event is deleted
  static Future<void> cancelNotification(
    int uniqueId,
  ) async {
    if (!_isSupportedPlatform) return;
    await flutterLocalNotificationsPlugin.cancel(uniqueId);
  }

  static Future<void> cancelRecurringTaskNotification({
    required int uniqueId,
    required List<int> daysOfWeek,
  }) async {
    if (!_isSupportedPlatform) return;

    for (int day in daysOfWeek) {
      await flutterLocalNotificationsPlugin.cancel(uniqueId + day);
    }
  }

  // Get the permission for notifications
  static Future<void> requestNotificationPermission() async {
    if (!_isSupportedPlatform) return;
    final bool? granted = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();

    if (granted != null && granted) {
    } else {
      Permission.notification.request();
      // openAppSettings();
    }
  }

  static String _inferTypeFromData(Map<String, dynamic> data) {
    if (data.containsKey('taskName') || data.containsKey('taskDateTime')) {
      return 'task';
    }

    if (data.containsKey('habitName') || data.containsKey('daysOfWeek')) {
      return 'habit';
    }

    if (data.containsKey('eventName') ||
        data.containsKey('eventStartDateTime')) {
      return 'event';
    }

    return 'unknown';
  }
}
