import 'dart:async';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:bloom/authentication_screens/authenticateuser.dart';
import 'package:bloom/firebase_options.dart';
import 'package:bloom/loading_animation.dart';
import 'package:bloom/models/note_layout.dart';
import 'package:bloom/notifications/notification.dart';
import 'package:bloom/screens/pomodoro_timer.dart';
import 'package:bloom/theme/color_scheme_provider.dart';
import 'package:bloom/theme/theme_provider.dart';
import 'package:bloom/windows_components/navigationrail.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:feedback/feedback.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase first (needed before runApp)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const BloomApp());

  // Non-critical async initializations (run after UI shows)
  unawaited(_postInitTasks());

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
    doWhenWindowReady(() {
      const initialSize = Size(800, 750);
      appWindow.size = initialSize;
      appWindow.minSize = initialSize;
      appWindow.show();
    });
  }
}

Future<void> _postInitTasks() async {
  await Future.wait([
    Future(() => tz.initializeTimeZones()),
    NotificationService.checkForUpdates(),
  ]);
}

class BloomApp extends StatefulWidget {
  const BloomApp({super.key});

  @override
  State<BloomApp> createState() => _BloomAppState();
}

class _BloomAppState extends State<BloomApp> {
  late Future<bool> _loadPrefsFuture;

  @override
  void initState() {
    super.initState();
    _loadPrefsFuture = _loadPrefs();
  }

  Future<bool> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('showHome') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _loadPrefsFuture,
      builder: (context, snapshot) {
        // Show splash/loader while waiting
        if (!snapshot.hasData) {
          return MaterialApp(
            color: Theme.of(context).colorScheme.surface,
            debugShowCheckedModeBanner: false,
            home: BreathingLoader(),
          );
        }

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => ColorSchemeProvider()),
            ChangeNotifierProvider(create: (_) => BackgroundImageNotifier()),
            ChangeNotifierProvider(create: (_) => EmojiNotifier()),
            ChangeNotifierProvider(create: (_) => PomodoroTimerProvider()),
            ChangeNotifierProvider(create: (_) => NavigationrailProvider()),
            ChangeNotifierProvider(create: (_) => EditorFocusProvider()),
          ],
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return CalendarControllerProvider(
                controller: EventController(),
                child: BetterFeedback(
                  theme: FeedbackThemeData(
                    bottomSheetDescriptionStyle: TextStyle(
                        color: themeProvider.themeData.colorScheme.primary),
                    bottomSheetTextInputStyle: TextStyle(
                        color: themeProvider.themeData.colorScheme.primary),
                    feedbackSheetColor:
                        themeProvider.themeData.colorScheme.surface,
                  ),
                  child: MaterialApp(
                    debugShowCheckedModeBanner: false,
                    title: kIsWeb == true ? 'Bloom Web' : 'Bloom',
                    theme: themeProvider.themeData,
                    darkTheme: themeProvider.themeData,
                    localizationsDelegates:
                        FlutterQuillLocalizations.localizationsDelegates,
                    home: AuthenticateUser(showHome: snapshot.data!),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
