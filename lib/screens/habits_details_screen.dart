import 'package:bloom/responsive/dimensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class HabitsDetailsScreen extends StatefulWidget {
  final String habitName;
  final String habitNotes;
  final DateTime habitDateTime;
  final List habitGroups;
  final String habitId;
  final int habitUniqueId;
  final List daysOfWeek;
  final List completedDaysOfWeek;
  final List completedDates;
  final DateTime addedOn;
  const HabitsDetailsScreen(
      {super.key,
      required this.habitName,
      required this.habitNotes,
      required this.habitDateTime,
      required this.habitGroups,
      required this.habitId,
      required this.habitUniqueId,
      required this.daysOfWeek,
      required this.completedDaysOfWeek,
      required this.addedOn,
      required this.completedDates});

  @override
  State<HabitsDetailsScreen> createState() => _HabitsDetailsScreenState();
}

class _HabitsDetailsScreenState extends State<HabitsDetailsScreen> {
  final user = FirebaseAuth.instance.currentUser;
  late final Set<String> completedDateStrings;
  @override
  void initState() {
    super.initState();
    completedDateStrings =
        widget.completedDates.map((d) => d.toString()).toSet();
  }

  // List<DateTime> _generateDaysInMonth(DateTime date) {
  //   final firstDay = DateTime(date.year, date.month, 1);
  //   final lastDay = DateTime(date.year, date.month + 1, 0);
  //   return List.generate(
  //     lastDay.day,
  //     (index) => DateTime(date.year, date.month, index + 1),
  //   );
  // }

  bool _isCompleted(DateTime date) {
    final formatted = DateFormat('yyyy-MM-dd').format(date);
    return completedDateStrings.contains(formatted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details'),
        actions: [
          // Button for more options like edit, delete etc
          PopupMenuButton(
            color: Theme.of(context).primaryColorLight,
            popUpAnimationStyle:
                AnimationStyle(duration: const Duration(milliseconds: 500)),
            itemBuilder: (context) => [
              // PopupMenuItem(
              //   value: 'edit',
              //   onTap: () => Navigator.of(context).push(MaterialPageRoute(
              //       builder: (context) => EventEditingScreen(
              //             eventId: widget.eventId,
              //             eventColorCode: widget.eventColorCode!,
              //             eventEndDateTime: widget.eventEndDateTime!,
              //             eventName: widget.eventName,
              //             eventNotes: widget.eventNotes,
              //             eventStartDateTime: widget.eventStartDateTime,
              //             eventUniqueId: widget.eventUniqueId,
              //           ))),
              //   child: Text(
              //     'Edit',
              //     style: TextStyle(
              //         color: Theme.of(context).textTheme.bodyMedium?.color),
              //   ),
              // ),
              PopupMenuItem(
                value: 'Delete',
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  // Delete the task from database
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user?.uid)
                      .collection('habits')
                      .doc(widget.habitId)
                      .delete();
                  // Show confirmation that task is deleted
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      margin: const EdgeInsets.all(6),
                      behavior: SnackBarBehavior.floating,
                      showCloseIcon: true,
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      content: Text('Habit deleted succesfully.'),
                    ),
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: MediaQuery.of(context).size.width < mobileWidth
              ? const EdgeInsets.all(0)
              : const EdgeInsets.symmetric(horizontal: 120),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name of the habit
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: Text(
                      widget.habitName,
                      style: const TextStyle(
                          fontSize: 20, overflow: TextOverflow.clip),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  // Notes of the habit
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: Text(
                      widget.habitNotes,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  // Time of the habit
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_filled_rounded),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          "At ${DateFormat('h:mm a').format(widget.habitDateTime)}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 10,
                  ),
                  // Habit Completion Calendar
                  // Calendar for showing completedDates
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    decoration: BoxDecoration(
                      // color: Theme.of(context).primaryColorLight,
                      borderRadius: BorderRadius.circular(18),
                      // border: Border.all(
                      //   width: 0.5,
                      //   color: Theme.of(context).primaryColor,
                      // ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("This Month's Progress",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                            "Since ${DateFormat('MMM, dd, yyyy').format(widget.addedOn)}"),
                        const SizedBox(
                          height: 10,
                        ),
                        TableCalendar(
                          firstDay: DateTime.utc(2023, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: DateTime.now(),
                          headerVisible: false,
                          calendarStyle:
                              const CalendarStyle(isTodayHighlighted: false),
                          calendarBuilders: CalendarBuilders(
                            todayBuilder: (context, date, _) {
                              final isDone = _isCompleted(date);
                              return Container(
                                margin: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: isDone
                                      ? Theme.of(context).primaryColor
                                      : null,
                                  border: Border.all(
                                      width: 0.5,
                                      color: Theme.of(context).primaryColor),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    color: isDone
                                        ? Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color
                                        : null,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                            defaultBuilder: (context, date, _) {
                              final isDone = _isCompleted(date);
                              return Container(
                                margin: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: isDone
                                      ? Theme.of(context).primaryColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    color: isDone
                                        ? Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // const Divider(),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
