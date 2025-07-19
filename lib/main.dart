import 'dart:async';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:bloom/ads/ad_service.dart';
import 'package:bloom/authentication_screens/authenticateuser.dart';
import 'package:bloom/firebase_options.dart';
import 'package:bloom/models/note_layout.dart';
import 'package:bloom/notifications/notification.dart';
// import 'package:bloom/screens/onboarding_screen.dart';
import 'package:bloom/screens/pomodoro_timer.dart';
import 'package:bloom/theme/color_scheme_provider.dart';
import 'package:bloom/theme/theme_provider.dart';
import 'package:bloom/windows_components/navigationrail.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:feedback/feedback.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    // options: const FirebaseOptions(
    //   apiKey: "AIzaSyALUS7E5fYJDI0mrcXWdahQ0d6TUKXs7fA",
    //   appId: "1:286072090024:web:d8c08532f528745261419d",
    //   messagingSenderId: "286072090024",
    //   projectId: "bloom-da824",
    //   measurementId: "G-ZTL6S21MJV",
    //   iosBundleId: "com.bloomproductive.bloom"
    // ),
  );
  // Initialize the GoogleADS SDK
  ADService().initializeADS();
  final prefs = await SharedPreferences.getInstance();
  final showHome = prefs.getBool('showHome') ?? false;

  // Check for the app update if any
  await NotificationService.checkForUpdates();

  runApp(
    BetterFeedback(
      child: MyApp(
        showHome: showHome,
      ),
    ),
  );

  // Custom Window settings
  if (Platform.isWindows) {
    doWhenWindowReady(() {
      var initialSize = const Size(800, 750);
      appWindow.size = initialSize;
      appWindow.minSize = initialSize;
      appWindow.show();
    });
  }
}

class MyApp extends StatelessWidget {
  final bool showHome;
  const MyApp({super.key, required this.showHome});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ColorSchemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => BackgroundImageNotifier(),
        ),
        ChangeNotifierProvider(
          create: (_) => EmojiNotifier(),
        ),
        ChangeNotifierProvider(
          create: (_) => PomodoroTimerProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => NavigationrailProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => EditorFocusProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return CalendarControllerProvider(
            controller: EventController(),
            child: BetterFeedback(
              theme: FeedbackThemeData(
                  background: Theme.of(context).primaryColorDark,
                  dragHandleColor: Theme.of(context).primaryColorLight,
                  bottomSheetDescriptionStyle: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color),
                  bottomSheetTextInputStyle: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color),
                  feedbackSheetColor:
                      Theme.of(context).scaffoldBackgroundColor),
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Bloom',
                theme: themeProvider.themeData,
                themeAnimationStyle: AnimationStyle(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOutBack),
                themeAnimationCurve: Curves.easeInOutBack,
                themeAnimationDuration: Duration(milliseconds: 800),
                localizationsDelegates:
                    FlutterQuillLocalizations.localizationsDelegates,
                home: AuthenticateUser(
                  showHome: showHome,
                ),
                // home: OnboardingScreen(onComplete: () {}),
              ),
            ),
          );
        },
      ).animate().fade(
            delay: const Duration(
              milliseconds: 800,
            ),
          ),
    );
  }
}
