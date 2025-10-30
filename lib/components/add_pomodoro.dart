import 'package:bloom/components/bloom_buttons.dart';
import 'package:bloom/components/mytextfield.dart';
import 'package:bloom/notifications/notification.dart';
import 'package:bloom/screens/pomodoro_timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddPomodoro extends StatefulWidget {
  final DateTime currentDateTime;
  const AddPomodoro({super.key, required this.currentDateTime});

  @override
  State<AddPomodoro> createState() => _AddPomodoroState();
}

class _AddPomodoroState extends State<AddPomodoro> {
  //
  final pomodoroController = TextEditingController();
  final pomodoroFocusNode = FocusNode();
  late DateTime? date;
  late TimeOfDay? time;
  int pomodoroDuration = 25;
  int shortBreakDuration = 5;
  int longBreakDuration = 15;
  int? uniqueId;
  late int numberOfPomodorosAdded;
  late String subscriptionPlan;

  // Init state
  @override
  void initState() {
    date = widget.currentDateTime;
    time = TimeOfDay.fromDateTime(widget.currentDateTime);
    numberOfPomodorosAddedCheck();
    super.initState();
  }

  // Check the NumberOfPomodoros added by the user
  void numberOfPomodorosAddedCheck() async {
    final user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((value) {
      if (value.exists && value.data()!.containsKey('subscriptionPlan')) {
        if (value['subscriptionPlan'] == 'ultra' ||
            value['subscriptionPlan'] == 'pro') {
          subscriptionPlan = value['subscriptionPlan'];
          numberOfPomodorosAdded = value['numberOfPomodorosAdded'] ?? 0;
          return;
        } else {
          subscriptionPlan = value['subscriptionPlan'];
          numberOfPomodorosAdded = value['numberOfPomodorosAdded'] ?? 0;
        }
      } else {
        subscriptionPlan = 'free';
        numberOfPomodorosAdded = 0;
      }
    });
  }

  // ignore: no_leading_underscores_for_local_identifiers
  void _showDurationPicker(BuildContext context, String durationType) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return DurationPicker(durationType: durationType);
      },
    );
  }

  // Date picker for events
  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.currentDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        date = picked;
      });
    }
  }

  // Time picker for events
  Future<void> selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        time = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<PomodoroTimerProvider>(context);
    // timerProvider.workDuration = Duration(minutes: pomodoroDuration);
    // timerProvider.shortBreakDuration = Duration(minutes: shortBreakDuration);
    // timerProvider.longBreakDuration = Duration(minutes: longBreakDuration);
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          // Pomodoro name heading
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Name',
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          // Pomodoro name text field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: MyTextfield(
              controller: pomodoroController,
              focusNode: pomodoroFocusNode,
              hintText: 'Study Computer Science',
              obscureText: false,
              textInputType: TextInputType.text,
              autoFocus: false,
              maxLines: 3,
              minLines: 1,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          // Other options heading
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Other',
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          // Group the start, end and color code
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Event start date and time
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'When',
                        style: TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      // Pomodoro date selection field
                      Flexible(
                        child: BloomMaterialListTile(
                          icon: SizedBox(),
                          iconLabelSpace: 0,
                          outerPadding: const EdgeInsets.all(0),
                          innerPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          labelStyle: TextStyle(),
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(14),
                          label: DateFormat('dd-MM-yy').format(date!),
                          textAlign: TextAlign.center,
                          onTap: selectDate,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Pomodoro time selection field
                      Flexible(
                        child: BloomMaterialListTile(
                          icon: SizedBox(),
                          iconLabelSpace: 0,
                          outerPadding: const EdgeInsets.all(0),
                          innerPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          labelStyle: TextStyle(),
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(14),
                          label: time!.format(context),
                          textAlign: TextAlign.center,
                          onTap: selectTime,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  // Pomodoro durations fields
                  Row(
                    children: [
                      const Text(
                        'Pomodoro',
                        style: TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      Flexible(
                        child: BloomMaterialListTile(
                          icon: SizedBox(),
                          iconLabelSpace: 0,
                          outerPadding: const EdgeInsets.all(0),
                          innerPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          labelStyle: TextStyle(),
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(14),
                          label: "${pomodoroDuration.toString()} minutes",
                          onTap: () {
                            _showDurationPicker(context, "Work");
                            setState(() {
                              pomodoroDuration =
                                  timerProvider.workDuration.inMinutes;
                            });
                          },
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      const Text(
                        'Short break',
                        style: TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      Flexible(
                        child: BloomMaterialListTile(
                          icon: SizedBox(),
                          iconLabelSpace: 0,
                          outerPadding: const EdgeInsets.all(0),
                          innerPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          labelStyle: TextStyle(),
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(14),
                          label: "${shortBreakDuration.toString()} minutes",
                          onTap: () {
                            _showDurationPicker(context, "Short Break");
                            setState(() {
                              shortBreakDuration =
                                  timerProvider.shortBreakDuration.inMinutes;
                            });
                          },
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      const Text(
                        'Long break',
                        style: TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      Flexible(
                        child: BloomMaterialListTile(
                          icon: SizedBox(),
                          iconLabelSpace: 0,
                          outerPadding: const EdgeInsets.all(0),
                          innerPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          labelStyle: TextStyle(),
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(14),
                          label: "${longBreakDuration.toString()} minutes",
                          onTap: () {
                            _showDurationPicker(context, "Long Break");
                            setState(() {
                              longBreakDuration =
                                  timerProvider.longBreakDuration.inMinutes;
                            });
                          },
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          // Create and start button
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                if (pomodoroController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      margin: const EdgeInsets.all(6),
                      behavior: SnackBarBehavior.floating,
                      showCloseIcon: true,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      content: Text('Give a name to start!'),
                    ),
                  );
                } else if ((pomodoroController.text.isNotEmpty &&
                        subscriptionPlan == 'free') &&
                    numberOfPomodorosAdded == 1) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      margin: const EdgeInsets.all(6),
                      behavior: SnackBarBehavior.floating,
                      showCloseIcon: true,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      content:
                          Text('You can only add one Pomodoro on free plan!'),
                    ),
                  );
                } else {
                  // Save to firebase
                  final user = FirebaseAuth.instance.currentUser;
                  final firestore = FirebaseFirestore.instance
                      .collection('users')
                      .doc(user?.uid)
                      .collection('pomodoros');
                  // Generate a docId
                  final pomodoroId = firestore.doc().id;
                  // Combine date and time
                  final dateTime = DateTime(date!.year, date!.month, date!.day,
                      time!.hour, time!.minute, 0);
                  // Generate a uniqueId for notifications purpose
                  uniqueId =
                      DateTime.now().millisecondsSinceEpoch.remainder(100000);
                  // Check and add to firebase
                  if (pomodoroController.text.trim().isNotEmpty) {
                    await firestore.doc(pomodoroId).set({
                      'pomodoroId': pomodoroId,
                      'pomodoroName': pomodoroController.text,
                      'pomodoroDuration': timerProvider.workDuration.inMinutes,
                      'shortBreakDuration':
                          timerProvider.shortBreakDuration.inMinutes,
                      'longBreakDuration':
                          timerProvider.longBreakDuration.inMinutes,
                      'pomodoroDateTime': dateTime,
                      'pomodoroUniqueId': uniqueId,
                      'isRunning': false
                    });
                    // Increment the numberOfPomodorosAdded and save
                    numberOfPomodorosAdded++;
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(user!.uid)
                        .set({
                      'numberOfPomodorosAdded': numberOfPomodorosAdded,
                    }, SetOptions(merge: true));
                  }
                  // Set the name of pomodoro to the provider class
                  setState(() {
                    timerProvider.state = pomodoroController.text.trim();
                  });
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PomodoroTimerScreen(
                            state: pomodoroController.text.trim(),
                          )));
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                width: double.maxFinite,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Text('Create and start timer',
                    style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onPrimary)),
              ),
            ),
          ),
          // ---- OR ---- block
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(
                    height: 40,
                  ),
                ),
              ),
              Text(
                'Or',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.grey[700]),
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(
                    height: 40,
                  ),
                ),
              ),
            ],
          ),
          // Schedule for later button
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                // Save to firebase
                final user = FirebaseAuth.instance.currentUser;
                final firestore = FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .collection('pomodoros');
                // Generate a docId
                final pomodoroId = firestore.doc().id;
                // Combine date and time
                final dateTime = DateTime(date!.year, date!.month, date!.day,
                    time!.hour, time!.minute, 0);
                // Generate a uniqueId for notifications purpose
                uniqueId =
                    DateTime.now().millisecondsSinceEpoch.remainder(100000);
                // Check and add to firebase

                if (pomodoroController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      margin: const EdgeInsets.all(6),
                      behavior: SnackBarBehavior.floating,
                      showCloseIcon: true,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      content: Text('Give a name to start!'),
                    ),
                  );
                } else if (pomodoroController.text.isNotEmpty &&
                    numberOfPomodorosAdded == 1) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      margin: const EdgeInsets.all(6),
                      behavior: SnackBarBehavior.floating,
                      showCloseIcon: true,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      content:
                          Text('You can only add one Pomodoro on free plan!'),
                    ),
                  );
                } else {
                  await firestore.doc(pomodoroId).set({
                    'pomodoroId': pomodoroId,
                    'pomodoroName': pomodoroController.text,
                    'pomodoroDuration': timerProvider.workDuration.inMinutes,
                    'shortBreakDuration':
                        timerProvider.shortBreakDuration.inMinutes,
                    'longBreakDuration':
                        timerProvider.longBreakDuration.inMinutes,
                    'pomodoroDateTime': dateTime,
                    'pomodoroUniqueId': uniqueId,
                    'isRunning': false
                  });
                  // Increment the numberOfPomodorosAdded and save
                  numberOfPomodorosAdded++;
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .set({
                    'numberOfPomodorosAdded': numberOfPomodorosAdded,
                  }, SetOptions(merge: true));
                }
                // Schedule notification
                await NotificationService.scheduleEventsNotification(
                  uniqueId!,
                  'You have a Pomodoro scheduled now!',
                  pomodoroController.text.trim(),
                  dateTime,
                  Importance.defaultImportance,
                  Priority.defaultPriority,
                );
                Navigator.pop(context);
                // Show confirmation of added
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    margin: const EdgeInsets.all(6),
                    behavior: SnackBarBehavior.floating,
                    showCloseIcon: true,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    content: Text('Pomodoro succesfully scheduled!'),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                width: double.maxFinite,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Theme.of(context).colorScheme.primary)),
                child: Text('Schedule for later',
                    style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onSurface)),
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }
}
