import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

@pragma('vm:entry-point')
class BackgroundService {
  // Initialize the background service for running pomodoro
  Future<void> initializeService() async {
    final service = FlutterBackgroundService();
    try {
      // Initialize only if the platform is Android or iOS
      if (Platform.isAndroid || Platform.isIOS) {
        await service.configure(
          androidConfiguration: AndroidConfiguration(
              onStart: onStart, // Main background task
              isForegroundMode: true,
              autoStartOnBoot: false,
              autoStart: true,
              foregroundServiceNotificationId: 1,
              foregroundServiceTypes: [
                AndroidForegroundType.dataSync,
              ],
              initialNotificationTitle: "Pomodoro started",
              initialNotificationContent:
                  "A Pomodoro is running in the background"),
          iosConfiguration: IosConfiguration(
            onForeground: onStart,
            onBackground: onIosBackground,
          ),
        );

        service.startService();
      } else {
        //
      }
    } catch (e) {
      //
    }
  }

  // On start function of the background service, has all the services needed to be started
  @pragma('vm:entry-point')
  static Future<void> onStart(ServiceInstance service) async {
    Duration elapsed = Duration.zero;
    int completedPomodoros = 0;
    String state = 'Work';
    bool isRunning = false;

    Duration workDuration = const Duration(minutes: 25);
    Duration shortBreakDuration = const Duration(minutes: 5);
    Duration longBreakDuration = const Duration(minutes: 15);

    service.on('startPomodoro').listen((data) {
      workDuration = Duration(seconds: data?['workDuration'] ?? 1500);
      shortBreakDuration =
          Duration(seconds: data?['shortBreakDuration'] ?? 300);
      longBreakDuration = Duration(seconds: data?['longBreakDuration'] ?? 900);
      state = data?['state'] ?? 'Work';
      completedPomodoros = data?['completedPomodoros'] ?? 0;
      isRunning = true;
    });

    service.on('pausePomodoro').listen((data) {
      isRunning = false;
    });

    service.on('resetPomodoro').listen((data) {
      elapsed = Duration.zero;
      completedPomodoros = 0;
      state = 'Work';
      isRunning = false;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isRunning) return;

      elapsed += const Duration(seconds: 1);
      final totalDuration = state == 'Work'
          ? workDuration
          : state == 'Break'
              ? shortBreakDuration
              : longBreakDuration;

      if (elapsed >= totalDuration) {
        elapsed = Duration.zero;

        if (state == 'Work') {
          completedPomodoros++;
          state = completedPomodoros % 4 == 0 ? 'Long Break' : 'Break';
        } else {
          state = 'Work';
        }

        // Show a notification
        FlutterBackgroundService().invoke('showNotification', {
          "title": "Pomodoro Completed",
          "body": state == 'Work' || state == state
              ? "Time to work!"
              : "Take a break, you've earned it!",
        });
      }

      service.invoke('update', {
        "state": state,
        "remainingTime": totalDuration.inSeconds - elapsed.inSeconds,
        "progress": elapsed.inSeconds / totalDuration.inSeconds,
        "completedPomodoros": completedPomodoros,
      });
    });
  }

// iOS background task handler
  @pragma('vm:entry-point')
  static bool onIosBackground(ServiceInstance service) {
    WidgetsFlutterBinding.ensureInitialized();
    return true;
  }
}
