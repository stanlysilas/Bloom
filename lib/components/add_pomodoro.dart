import 'package:bloom/components/mybuttons.dart';
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
  late DateTime? date;
  late TimeOfDay? time;
  int pomodoroDuration = 25;
  int shortBreakDuration = 5;
  int longBreakDuration = 15;
  int? uniqueId;
  late int numberOfPomodorosAdded;

  // Init state
  @override
  void initState() {
    date = widget.currentDateTime;
    time = TimeOfDay.fromDateTime(widget.currentDateTime);
    numberOfPomodorosAddedCheck();
    super.initState();
  }

  void numberOfPomodorosAddedCheck() async {
    final user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((value) {
      if (value.exists && value.data()!.containsKey('numberOfPomodorosAdded')) {
        numberOfPomodorosAdded = value['numberOfPomodorosAdded'] ?? 0;
      } else {
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
    return Column(
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
              color: Theme.of(context).primaryColorLight,
              borderRadius: BorderRadius.circular(10),
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
                      child: ExtraOptionsButton(
                        outerPadding: const EdgeInsets.only(left: 14),
                        decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(8)),
                        label: DateFormat('dd-MM-yy').format(date!),
                        textAlign: TextAlign.center,
                        onTap: selectDate,
                      ),
                    ),
                    // Pomodoro time selection field
                    Flexible(
                      child: ExtraOptionsButton(
                        outerPadding: const EdgeInsets.only(left: 14),
                        decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(8)),
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
                      child: ExtraOptionsButton(
                        outerPadding: const EdgeInsets.only(left: 14),
                        decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(8)),
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
                      child: ExtraOptionsButton(
                        outerPadding: const EdgeInsets.only(left: 14),
                        decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(8)),
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
                      child: ExtraOptionsButton(
                        outerPadding: const EdgeInsets.only(left: 14),
                        decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(8)),
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
            onTap: () async {
              if (pomodoroController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    margin: const EdgeInsets.all(6),
                    behavior: SnackBarBehavior.floating,
                    showCloseIcon: true,
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    content: Text(
                      'Give a name to start!',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
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
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    content: Text(
                      'You can only add one Pomodoro on free plan!',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
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
                borderRadius: BorderRadius.circular(1000),
                color: Theme.of(context).primaryColor,
              ),
              child: const Text('Create and start timer',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
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
              'OR',
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
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    content: Text(
                      'Give a name to start!',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
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
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    content: Text(
                      'You can only add one Pomodoro on free plan!',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
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
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  content: Text(
                    'Pomodoro succesfully scheduled!',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              width: double.maxFinite,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1000),
                color: Theme.of(context).primaryColor,
              ),
              child: const Text('Schedule for later',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
      ],
    );
  }
}
