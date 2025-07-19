import 'package:bloom/authentication_screens/firebase_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Generate a unique id for each notification
  int generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }

  // Check firebase for any app updates and send instant notification if yes
  static Future<void> checkForUpdates() async {
    FirebaseFirestore.instance
        .collection('appData')
        .doc('appData')
        .get()
        .then((value) {
      if (value['latestAndroidVersion'] != '2.2.1') {
        showInstantNotification(
            'Bloom has an update!',
            'Version ${value['latestAndroidVersion']} is now available to download',
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

  // Show an instant notification
  static Future<void> showInstantNotification(
      String title, String body, int uniqueId) async {
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

  // Show a event notification
  static Future<void> scheduleEventsNotification(
      int uniqueId,
      String title,
      String body,
      DateTime scheduledDate,
      Importance importance,
      Priority priority) async {
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
        matchDateTimeComponents: DateTimeComponents
            .dayOfWeekAndTime, // Repeats every selected weekday
        // uiLocalNotificationDateInterpretation:
        //     UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  // Cancel the notification if the task/event is deleted
  static Future<void> cancelNotification(
    int uniqueId,
  ) async {
    await flutterLocalNotificationsPlugin.cancel(uniqueId);
  }

  // Get the permission for notifications
  static Future<void> requestNotificationPermission() async {
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
}
