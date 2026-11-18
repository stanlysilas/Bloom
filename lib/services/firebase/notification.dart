import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static bool get _isSupportedPlatform => !kIsWeb;

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static int generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }

  static Future<void> onDidReceiveNotification(
    NotificationResponse notificationResponse,
  ) async {}

  static Future<bool> init() async {
    if (!_isSupportedPlatform) return false;

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings(
      '@mipmap/default_app_icon_notification',
    );

    const DarwinInitializationSettings iOSInitializationSettings =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iOSInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotification,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveNotification,
    );

    return true;
  }

  static Future<void> showInstantNotification(
    String title,
    String body,
    int uniqueId,
  ) async {
    if (!_isSupportedPlatform) return;

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
      uniqueId,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  static Future<void> scheduleTasksNotification(
    int uniqueId,
    String title,
    String body,
    DateTime scheduledDate,
    Importance importance,
    Priority priority,
  ) async {
    if (!_isSupportedPlatform) return;

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
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

    await flutterLocalNotificationsPlugin.zonedSchedule(
      uniqueId,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
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

    for (final day in daysOfWeek) {
      tz.TZDateTime nextInstance(int targetDay) {
        final now = tz.TZDateTime.now(tz.local);

        var scheduled = tz.TZDateTime(
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

  static Future<void> scheduleEventsNotification(
    int uniqueId,
    String title,
    String body,
    DateTime scheduledDate,
    Importance importance,
    Priority priority,
  ) async {
    if (!_isSupportedPlatform) return;

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
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

    await flutterLocalNotificationsPlugin.zonedSchedule(
      uniqueId,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  static Future<void> schedulePomodoroNotification(
    int uniqueId,
    String title,
    String body,
    DateTime scheduledDate,
    Importance importance,
    Priority priority,
  ) async {
    if (!_isSupportedPlatform) return;

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
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

    await flutterLocalNotificationsPlugin.zonedSchedule(
      uniqueId,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  static Future<void> scheduleRecurringNotification(
    int uniqueId,
    String title,
    String body,
    DateTime scheduleDateTime,
    Importance importance,
    Priority priority,
    String repeat,
  ) async {
    if (!_isSupportedPlatform) return;

    tz.TZDateTime nextInstanceOfTime() {
      final now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime? scheduledDate;

      if (repeat == 'Daily') {
        scheduledDate = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          scheduleDateTime.hour,
          scheduleDateTime.minute,
          scheduleDateTime.second,
        );
      }

      if (scheduledDate == null) {
        return now;
      }

      if (scheduledDate.isBefore(now)) {
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
          'recurring_notifications_id',
          'Recurring Notifications',
          importance: importance,
          priority: priority,
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> scheduleRecurringHabitNotification(
    int uniqueId,
    String title,
    String body,
    DateTime scheduleDateTime,
    List<int> daysOfWeek,
    Importance importance,
    Priority priority,
  ) async {
    if (!_isSupportedPlatform) return;

    for (final day in daysOfWeek) {
      tz.TZDateTime nextInstanceOfDay(int targetWeekday) {
        final now = tz.TZDateTime.now(tz.local);

        var scheduledDate = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          scheduleDateTime.hour,
          scheduleDateTime.minute,
          scheduleDateTime.second,
        );

        while (scheduledDate.weekday != targetWeekday + 1 ||
            scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }

        return scheduledDate;
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        uniqueId + day,
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

    for (final day in daysOfWeek) {
      await flutterLocalNotificationsPlugin.cancel(uniqueId + day);
    }
  }

  static Future<void> requestNotificationPermission() async {
    if (!_isSupportedPlatform) return;

    final androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();
  }
}
