import 'dart:async';

import 'package:bloom/background_services/background_service.dart';
import 'package:bloom/notifications/notification.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class PomodoroTimerScreen extends StatefulWidget {
  final String? pomodoroId;
  final int? pomodoroUniqueId;
  final String state;
  final PomodoroTimerProvider? pomodoroTimerProvider;
  const PomodoroTimerScreen(
      {super.key,
      required this.state,
      this.pomodoroTimerProvider,
      this.pomodoroId,
      this.pomodoroUniqueId});

  @override
  State<PomodoroTimerScreen> createState() => _PomodoroTimerScreenState();
}

class _PomodoroTimerScreenState extends State<PomodoroTimerScreen> {
  // Required variables
  late BannerAd bannerAd;
  bool isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    // initBannerAd();
  }

  // Banner ADs initialization method
  initBannerAd() {
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: "ca-app-pub-5607290715305671/1570163196",
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              margin: const EdgeInsets.all(6),
              behavior: SnackBarBehavior.floating,
              showCloseIcon: true,
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              content: Text(
                'Failed to load the Ad. ${error.message}',
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color),
              )));
        },
      ),
      request: const AdRequest(),
    );

    bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<PomodoroTimerProvider>(context);

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Pomodoro',
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: const [
          // Button to display more options sheet
          // IconButton(
          //     onPressed: () {
          //       // Display a bottom sheet with more options
          //     },
          //     icon: const Icon(Iconsax.more)),
        ],
      ),
      body: Container(
        height: double.maxFinite,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: const BoxDecoration(
            // image: DecorationImage(
            //     fit: BoxFit.cover,
            //     image: AssetImage(
            //         'assets/pomodoro_backgrounds/cozy_summer_workspace.jpg')),
            ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Stack the timer and progress indicator
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 200,
                  width: 200,
                  child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1500),
                      tween: Tween<double>(
                          begin: timerProvider.progress,
                          end: timerProvider.progress),
                      builder: (context, value, _) {
                        return CircularProgressIndicator(
                          value: value,
                          strokeWidth: 6,
                          color: Theme.of(context).primaryColor,
                          strokeCap: StrokeCap.round,
                          backgroundColor: Theme.of(context).primaryColorLight,
                        );
                      }),
                ),
                Center(
                  child: Text(
                    _formatDuration(timerProvider.remainingTime),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 10),
            // Title of pomodoro
            Text(
              timerProvider.state == 'Work'
                  ? widget.state
                  : timerProvider.state,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (timerProvider.isRunning) {
                      timerProvider.pauseTimer();
                    } else {
                      timerProvider.startTimer();
                      // Initialize flutter background service for running pomodoro in the background
                      BackgroundService().initializeService();
                    }
                  },
                  style: ButtonStyle(
                      backgroundColor:
                          const WidgetStatePropertyAll(Colors.transparent),
                      side: WidgetStatePropertyAll(BorderSide(
                          color: Theme.of(context).primaryColor, width: 2))),
                  child: Text(
                    timerProvider.isRunning ? 'Pause' : 'Start',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: timerProvider.resetTimer,
                  style: ButtonStyle(
                      backgroundColor:
                          const WidgetStatePropertyAll(Colors.transparent),
                      side: WidgetStatePropertyAll(BorderSide(
                          color: Theme.of(context).primaryColor, width: 2))),
                  child: Text(
                    'Reset',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                ),
              ],
            ),
            // Button to change or turn off background ambient music
            ElevatedButton(
                onPressed: () {},
                child: const Row(
                  children: [Icon(Icons.play_arrow_rounded)],
                )),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                timerProvider.longBreakAfter,
                (index) => Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: timerProvider.completedPomodoros == 4
                        ? const SizedBox()
                        : Icon(
                            Icons.timer,
                            color: index < timerProvider.completedPomodoros
                                ? Colors.red
                                : Colors.grey,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          // Display and AD in between the events tile and tasks tile (testing)
          isAdLoaded
              ? SizedBox(
                  height: bannerAd.size.height.toDouble(),
                  width: bannerAd.size.width.toDouble(),
                  child: Center(child: AdWidget(ad: bannerAd)),
                )
              : const SizedBox(),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class PomodoroTimerProvider extends ChangeNotifier {
  Duration workDuration = const Duration(minutes: 25);
  Duration shortBreakDuration = const Duration(minutes: 5);
  Duration longBreakDuration = const Duration(minutes: 15);
  int longBreakAfter = 4;
  int completedPomodoros = 0;
  bool isRunning = false;
  String state = 'Work'; // Can be 'Work', 'Break', or 'Long Break'
  Timer? _timer;
  Duration elapsed = Duration.zero;

  Duration get remainingTime {
    final totalDuration = state == 'Work'
        ? workDuration
        : state == 'Break'
            ? shortBreakDuration
            : longBreakDuration;
    return totalDuration - elapsed;
  }

  double get progress {
    final totalDuration = state == 'Work'
        ? workDuration
        : state == 'Break'
            ? shortBreakDuration
            : longBreakDuration;
    return 1.0 - (remainingTime.inSeconds / totalDuration.inSeconds);
  }

  // Start a background service for running the pomodoro timer
  void startBackgroundService() {
    FlutterBackgroundService().invoke('startPomodoro', {
      "workDuration": workDuration.inSeconds,
      "shortBreakDuration": shortBreakDuration.inSeconds,
      "longBreakDuration": longBreakDuration.inSeconds,
      "state": state,
      "completedPomodoros": completedPomodoros,
    });
  }

  void startTimer() {
    if (isRunning) return;

    isRunning = true;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsed = elapsed + const Duration(seconds: 1);

      if (remainingTime <= Duration.zero) {
        _completeCycle();
      }

      notifyListeners();
    });
  }

  void pauseTimer() {
    isRunning = false;
    FlutterBackgroundService().invoke('pausePomodoro');
    _timer?.cancel();
    notifyListeners();
  }

  void resetTimer() {
    isRunning = false;
    elapsed = Duration.zero;
    state = 'Work';
    completedPomodoros = 0;
    FlutterBackgroundService().invoke('resetPomodoro');
    _timer?.cancel();
    notifyListeners();
  }

  void _completeCycle() {
    elapsed = Duration.zero;

    if (state == 'Work') {
      completedPomodoros++;
      completedPomodoros == 4
          ? NotificationService.showInstantNotification('Pomodoro Completed!',
              'Take a long break, drink water, take a walk...', 4)
          : NotificationService.showInstantNotification(
              'Pomodoro Completed!', 'Take a short break', completedPomodoros);
      state = completedPomodoros % longBreakAfter == 0 ? 'Long Break' : 'Break';
    } else {
      state = 'Work';
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class DurationPicker extends StatefulWidget {
  final String durationType; // "Work", "Short Break", "Long Break"

  const DurationPicker({required this.durationType, super.key});

  @override
  State<DurationPicker> createState() => DurationPickerState();
}

class DurationPickerState extends State<DurationPicker> {
  int selectedMinutes = 25; // Default value for "Work"

  @override
  void initState() {
    super.initState();
    final timerProvider =
        Provider.of<PomodoroTimerProvider>(context, listen: false);
    if (widget.durationType == "Work") {
      selectedMinutes = timerProvider.workDuration.inMinutes;
    } else if (widget.durationType == "Short Break") {
      selectedMinutes = timerProvider.shortBreakDuration.inMinutes;
    } else if (widget.durationType == "Long Break") {
      selectedMinutes = timerProvider.longBreakDuration.inMinutes;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Select ${widget.durationType} Duration',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: CupertinoPicker(
              itemExtent: 42,
              useMagnifier: true,
              looping: true,
              backgroundColor: Colors.transparent,
              onSelectedItemChanged: (int index) {
                setState(() {
                  selectedMinutes = index + 1;
                });
              },
              scrollController: FixedExtentScrollController(
                initialItem: selectedMinutes - 1,
              ),
              children: List<Widget>.generate(60, (int index) {
                return Center(
                  child: Text('${index + 1} minutes'),
                );
              }),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Update the provider's duration
              final timerProvider =
                  Provider.of<PomodoroTimerProvider>(context, listen: false);

              if (widget.durationType == "Work") {
                timerProvider.workDuration = Duration(minutes: selectedMinutes);
              } else if (widget.durationType == "Short Break") {
                timerProvider.shortBreakDuration =
                    Duration(minutes: selectedMinutes);
              } else if (widget.durationType == "Long Break") {
                timerProvider.longBreakDuration =
                    Duration(minutes: selectedMinutes);
              }

              Navigator.of(context).pop();
            },
            style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(
                    Theme.of(context).textTheme.bodyMedium?.color),
                backgroundColor:
                    WidgetStatePropertyAll(Theme.of(context).primaryColor)),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
