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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name of the habit
                Text(
                  widget.habitName,
                  style: const TextStyle(
                      fontSize: 20, overflow: TextOverflow.clip),
                ),
                const SizedBox(
                  height: 5,
                ),
                // Notes of the habit
                Text(
                  widget.habitNotes,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(
                  height: 14,
                ),
                // Time of the habit
                Row(
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
                  padding: const EdgeInsets.all(8),
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
                        calendarStyle: const CalendarStyle(
                          isTodayHighlighted: false
                        ),
                        calendarBuilders: CalendarBuilders(
                          todayBuilder: (context, date, _) {
                            final isDone = _isCompleted(date);
                            return Container(
                              margin: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: isDone ? Theme.of(context).primaryColor : null,
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
    );
  }
}
