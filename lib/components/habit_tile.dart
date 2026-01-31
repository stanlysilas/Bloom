import 'package:bloom/components/delete_confirmation_dialog.dart';
import 'package:bloom/notifications/notification.dart';
import 'package:bloom/screens/habits_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class HabitTile extends StatefulWidget {
  final String habitId;
  final String habitName;
  final String habitNotes;
  final List habitGroups;
  final DateTime habitDateTime;
  final List daysOfWeek;
  final List completedDaysOfWeek;
  final DateTime addedOn;
  final int habitUniqueId;
  final List completedDates;
  final EdgeInsetsGeometry? innerPadding;
  final EdgeInsetsGeometry? margin;
  final int bestStreak;
  final int currentStreak;
  const HabitTile(
      {super.key,
      required this.habitId,
      required this.habitName,
      required this.habitNotes,
      required this.habitDateTime,
      required this.habitGroups,
      required this.daysOfWeek,
      required this.completedDaysOfWeek,
      required this.addedOn,
      required this.habitUniqueId,
      this.innerPadding,
      this.margin,
      required this.completedDates,
      required this.bestStreak,
      required this.currentStreak});

  @override
  State<HabitTile> createState() => _HabitTileState();
}

class _HabitTileState extends State<HabitTile> {
  // Reuired variables
  final user = FirebaseAuth.instance.currentUser;
  final List<String> daysOfWeekString = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  bool? alreadyCompleted;

  @override
  void initState() {
    super.initState();
    checkAndResetStreak(widget.completedDates);
  }

  /// Checks and Resets the currentStreak field in Firestore
  /// for the specific Habit if the completedDates field
  /// doesn't contain the 2 consecutive days dates.
  void checkAndResetStreak(List habitData) {
    List<dynamic> completedDates = habitData;
    if (completedDates.isEmpty) return;

    // Sort dates to get the most recent one
    completedDates.sort();
    String lastDateStr = completedDates.last;
    DateTime lastDate = DateFormat('yyyy-MM-dd').parse(lastDateStr);

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    int difference = today.difference(lastDate).inDays;

    // If more than 1 day has passed since the last completion
    if (difference > 1) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('habits')
          .doc(widget.habitId)
          .update({'currentStreak': 0});
    }
  }

  /// Add or remove the current date from Firestore for the specific Habit.
  /// Vibe Coded with Gemini AI.
  void toggleTodayCompletion() {
    var currentStreak = widget.currentStreak;
    var bestStreak = widget.bestStreak;
    final firestore = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('habits')
        .doc(widget.habitId);

    DateTime now = DateTime.now();
    String dateKey = DateFormat('yyyy-MM-dd').format(now);
    String timeKey = DateFormat('h: mm a').format(now);
    DateTime yesterday = now.subtract(const Duration(days: 1));
    String yesterdayKey = DateFormat('yyyy-MM-dd').format(yesterday);

    alreadyCompleted = widget.completedDates.contains(dateKey);

    if (alreadyCompleted == true) {
      // UNCHECKING: Remove date and decrement current streak
      setState(() {
        widget.completedDates.remove(dateKey);
        // When unchecking today, the streak becomes whatever it was yesterday
        // Logic: If yesterday was completed, currentStreak is now the length of the chain ending yesterday.
        // For simplicity in a toggle, we decrement.
        currentStreak = (currentStreak > 0) ? currentStreak - 1 : 0;
      });

      firestore.update({
        'completedDates': FieldValue.arrayRemove([dateKey]),
        'currentStreak': currentStreak,
      });
    } else {
      // CHECKING: Add date and calculate streak logic
      setState(() {
        widget.completedDates.add(dateKey);

        bool completedYesterday = widget.completedDates.contains(yesterdayKey);

        if (completedYesterday) {
          // Maintain momentum
          currentStreak += 1;
        } else {
          // Chain broken or first time: Reset current streak to 1
          currentStreak = 1;
        }

        if (currentStreak > bestStreak) {
          bestStreak = currentStreak;
        }
      });

      firestore.update({
        'completedDates': FieldValue.arrayUnion([dateKey]),
        'currentStreak': currentStreak,
        'bestStreak': bestStreak,
        'lastUpdated': dateKey,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: InkWell(
              onTap: () async {
                showDialog(
                    context: context,
                    builder: (context) {
                      return DeleteConfirmationDialog(
                          onPressed: () {
                            final user = FirebaseAuth.instance.currentUser;
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(user?.uid)
                                .collection('habits')
                                .doc(widget.habitId)
                                .delete();
                            NotificationService.cancelNotification(
                                widget.habitUniqueId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                margin: const EdgeInsets.all(6),
                                behavior: SnackBarBehavior.floating,
                                showCloseIcon: true,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                content: Wrap(
                                  children: [
                                    Text('Deleted: '),
                                    Text(
                                      widget.habitName,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  ],
                                ),
                              ),
                            );
                            Navigator.of(context).pop();
                          },
                          objectName: widget.habitName);
                    });
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.delete_rounded,
                    color: Theme.of(context).colorScheme.onErrorContainer),
              ),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Navigate to habits screen or show a modal bottom sheet
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => HabitsDetailsScreen(
                    habitName: widget.habitName,
                    habitNotes: widget.habitNotes,
                    habitDateTime: widget.habitDateTime,
                    habitGroups: widget.habitGroups,
                    habitId: widget.habitId,
                    habitUniqueId: widget.habitUniqueId,
                    addedOn: widget.addedOn,
                    daysOfWeek: widget.daysOfWeek,
                    completedDaysOfWeek: widget.completedDaysOfWeek,
                    completedDates: widget.completedDates,
                  )));
          // showModalBottomSheet(
          //     context: context,
          //     backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          //     showDragHandle: true,
          //     isScrollControlled: true,
          //     useSafeArea: true,
          //     builder: (context) {
          //       return HabitsDetailsScreen(
          //         habitName: widget.habitName,
          //         habitNotes: widget.habitNotes,
          //         habitDateTime: widget.habitDateTime,
          //         habitGroups: widget.habitGroups,
          //         habitId: widget.habitId,
          //         habitUniqueId: widget.habitUniqueId,
          //         addedOn: widget.addedOn,
          //         daysOfWeek: widget.daysOfWeek,
          //         completedDaysOfWeek: widget.completedDaysOfWeek,
          //         completedDates: widget.completedDates,
          //       );
          //     });
        },
        child: Padding(
          padding: widget.innerPadding ?? const EdgeInsets.all(0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main details of the Habit
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 6,
                children: [
                  // Icon or emoji of the habit
                  Container(
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color:
                            Theme.of(context).colorScheme.secondaryContainer),
                    child: Row(
                      children: [
                        Icon(Icons.repeat,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  // Name and notes or description of the habit
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.habitName,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.habitNotes != '')
                          Text(
                            widget.habitNotes,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        Text(
                          "At ${DateFormat('h:mm a').format(widget.habitDateTime)}",
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  // Icon or emoji of the habit
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                          widget.completedDates.contains(
                                  DateFormat('yyyy-MM-dd')
                                      .format(DateTime.now()))
                              ? '🔥: ${widget.currentStreak} days'
                              : '⚠️: ${widget.currentStreak} days',
                          style: widget.completedDates.contains(
                                  DateFormat('yyyy-MM-dd')
                                      .format(DateTime.now()))
                              ? null
                              : TextStyle(
                                  color: Theme.of(context).colorScheme.error)),
                      Text(
                        'Best: ${widget.bestStreak} days',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  // Dates marked for the habit
                  Checkbox(
                    value: widget.completedDates.contains(
                        DateFormat('yyyy-MM-dd').format(DateTime.now())),
                    onChanged: (value) {
                      toggleTodayCompletion();
                      setState(() {
                        alreadyCompleted = value!;
                      });
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  // ...List.generate(7, (value) {
                  //   return Material(
                  //     borderRadius: BorderRadius.circular(6),
                  //     color: widget.daysOfWeek.contains(value)
                  //         ? widget.completedDaysOfWeek.contains(value)
                  //             ? Theme.of(context).colorScheme.primary
                  //             : Theme.of(context).colorScheme.secondaryContainer
                  //         : Colors.transparent,
                  //     child: InkWell(
                  //       borderRadius: BorderRadius.circular(6),
                  //       onTap: checkDay(value)
                  //           ? () async {
                  //               // Update the completedDaysOfWeek in database
                  //               if (widget.daysOfWeek.contains(value)) {
                  //                 updateCompletedDaysOfWeek(value);
                  //               }
                  //               // Update the completedDaysOfWeek locally when tapped on the particular day button
                  //               setState(() {
                  //                 if (widget.completedDaysOfWeek.contains(value)) {
                  //                   widget.completedDaysOfWeek.remove(value);
                  //                 } else {
                  //                   widget.completedDaysOfWeek.add(value);
                  //                 }
                  //               });
                  //             }
                  //           : null,
                  //       child: Container(
                  //         height: 20,
                  //         width: 20,
                  //         alignment: Alignment.center,
                  //         child: Text(
                  //           widget.daysOfWeek.contains(value)
                  //               ? daysOfWeekString[value]
                  //               : '',
                  //           style: TextStyle(
                  //               fontSize: 10,
                  //               color: widget.daysOfWeek.contains(value)
                  //                   ? widget.completedDaysOfWeek.contains(value)
                  //                       ? Theme.of(context).colorScheme.onPrimary
                  //                       : Theme.of(context)
                  //                           .colorScheme
                  //                           .onSecondaryContainer
                  //                   : Colors.transparent),
                  //         ),
                  //       ),
                  //     ),
                  //   );
                  // }),
                ],
              ),
              // Heatmap of the Habit
              // HeatMap(
              //   size: 12,
              //   borderRadius: 3,
              //   showColorTip: false,
              //   showText: false,
              //   endDate: DateTime(
              //       DateTime.now().year, DateTime.now().month + 1, 0),
              //   scrollable: true,
              //   colorMode: ColorMode.color,
              //   colorsets: {1: Theme.of(context).colorScheme.primary},
              //   datasets: heatMapDates(),
              //   onClick: (dateTime) {
              //     return Navigator.of(context).push(MaterialPageRoute(
              //         builder: (context) => HabitsDetailsScreen(
              //               habitName: widget.habitName,
              //               habitNotes: widget.habitNotes,
              //               habitDateTime: widget.habitDateTime,
              //               habitGroups: widget.habitGroups,
              //               habitId: widget.habitId,
              //               habitUniqueId: widget.habitUniqueId,
              //               addedOn: widget.addedOn,
              //               daysOfWeek: widget.daysOfWeek,
              //               completedDaysOfWeek: widget.completedDaysOfWeek,
              //               completedDates: widget.completedDates,
              //             )));
              //   },
              // )
            ],
          ),
        ),
      ),
    );
  }
}
