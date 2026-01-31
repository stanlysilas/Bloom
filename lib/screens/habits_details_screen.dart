import 'package:bloom/components/delete_confirmation_dialog.dart';
import 'package:bloom/responsive/dimensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:intl/intl.dart';

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
  final IconData? appBarLeading;
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
      required this.completedDates,
      this.appBarLeading});

  @override
  State<HabitsDetailsScreen> createState() => _HabitsDetailsScreenState();
}

class _HabitsDetailsScreenState extends State<HabitsDetailsScreen> {
  final user = FirebaseAuth.instance.currentUser;
  late final Set<String> completedDateStrings;
  late int currentStreak = 0;
  late int bestStreak = 0;
  late double averageStreak = 0;
  @override
  void initState() {
    super.initState();
    getHabitData();
    completedDateStrings =
        widget.completedDates.map((d) => d.toString()).toSet();
    // print(completedDateStrings);
  }

  /// Retrieve the [currentStreak] and [bestStreak] for the Habit
  void getHabitData() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('habits')
        .doc(widget.habitId)
        .get()
        .then((value) {
      if (value.exists && value.data() != null) {
        setState(() {
          // Use the null-coalescing operator (??) to provide 0 if the field is missing
          currentStreak = value.data()?['currentStreak'] ?? 0;
          bestStreak = value.data()?['bestStreak'] ?? 0;
          averageStreak = (currentStreak + bestStreak) / 2;
        });
      }
    });
  }

  /// Convert the dates list into a [Map<DateTime, int>] to display it as a [HeatMap]
  Map<DateTime, int> heatMapDates() {
    // 1. Initialize the map
    Map<DateTime, int> heatmapValues = {};

    for (var d in widget.completedDates) {
      // 2. Parse the individual string 'd'
      DateTime date = DateFormat('yyyy-MM-dd').parse(d);

      // 3. Increment the count for that specific date
      heatmapValues[date] = (heatmapValues[date] ?? 0) + 1;
    }

    return heatmapValues;
  }

  // List<DateTime> _generateDaysInMonth(DateTime date) {
  //   final firstDay = DateTime(date.year, date.month, 1);
  //   final lastDay = DateTime(date.year, date.month + 1, 0);
  //   return List.generate(
  //     lastDay.day,
  //     (index) => DateTime(date.year, date.month, index + 1),
  //   );
  // }

  // bool _isCompleted(DateTime date) {
  //   final formatted = DateFormat('yyyy-MM-dd').format(date);
  //   // print(formatted);
  //   return completedDateStrings.contains(formatted);
  // }

  List<FlSpot> _generateYearlySpots() {
    final now = DateTime.now();
    final List<FlSpot> spots = [];

    for (int month = 1; month <= 12; month++) {
      // 1. Calculate total days in that specific month
      final lastDay = DateTime(now.year, month + 1, 0).day;

      // 2. Count completions in your list for that month/year
      int completions = 0;
      for (String dateStr in completedDateStrings) {
        final date = DateTime.parse(dateStr);
        if (date.month == month && date.year == now.year) {
          completions++;
        }
      }

      // 3. Calculate percentage (0.0 to 100.0)
      double percentage = (completions / lastDay) * 100;
      spots.add(FlSpot(month.toDouble(), percentage));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
// 1. Get current time and relevant start dates
    final now = DateTime.now();

// Start date for Consistency (when you actually started the habit)
    final habitStartedThisYear = widget.addedOn.year == now.year;
    final trackingStart = habitStartedThisYear
        ? DateTime(
            widget.addedOn.year, widget.addedOn.month, widget.addedOn.day)
        : DateTime(now.year, 1, 1);

// Start date for the full Calendar Year
    final yearStart = DateTime(now.year, 1, 1);
    final yearEnd = DateTime(now.year, 12, 31);

    final monthStart =
        (habitStartedThisYear && widget.addedOn.month == now.month)
            ? DateTime(
                widget.addedOn.year, widget.addedOn.month, widget.addedOn.day)
            : DateTime(now.year, now.month, 1);

// 2. Calculate denominators
// For Yearly Progress: Total days in the calendar year (365 or 366)
    final totalDaysInYear = yearEnd.difference(yearStart).inDays + 1;
// For Consistency: Days since you actually started tracking
    final daysSinceTrackingStarted = now.difference(trackingStart).inDays + 1;
    final daysInMonth = now.difference(monthStart).inDays + 1;

// 3. Count completions
    int yearCompletions = 0;
    int monthCompletions = 0;

    for (String dateStr in completedDateStrings) {
      final date = DateTime.parse(dateStr);

      if (date.year == now.year) {
        yearCompletions++;

        if (date.month == now.month &&
            date.isAfter(monthStart.subtract(const Duration(seconds: 1)))) {
          monthCompletions++;
        }
      }
    }

// 4. Calculate Final Values
// Yearly Progress: Percentage of the entire year completed (e.g. 1/365)
    final double yearProgressValue =
        (yearCompletions / totalDaysInYear).clamp(0.0, 1.0);

// Consistency Rate: How well you've done since starting (e.g. 1/3)
    final double consistencyRate =
        (yearCompletions / daysSinceTrackingStarted).clamp(0.0, 1.0);

// Monthly Value
    final double monthValue = (monthCompletions / daysInMonth).clamp(0.0, 1.0);

// Strings for display (optional)
    final yearPercentage = (yearProgressValue * 100).toStringAsFixed(0);
    final monthPercentage = (monthValue * 100).toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.surfaceContainer)),
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(widget.appBarLeading ?? Icons.arrow_back,
                color: Colors.grey)),
        title: Text('Details',
            style: TextStyle(
                fontFamily: 'ClashGrotesk', fontWeight: FontWeight.w500)),
        actions: [
          // Button for more options like edit, delete etc
          PopupMenuButton(
            iconColor: Colors.grey,
            style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.surfaceContainer)),
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
                  showAdaptiveDialog(
                      context: context,
                      builder: (context) {
                        return DeleteConfirmationDialog(
                            onPressed: () async {
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
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  content: Text('Habit deleted succesfully.'),
                                ),
                              );
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            objectName: widget.habitName);
                      });
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
              : const EdgeInsets.symmetric(horizontal: 250),
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
                  if (widget.habitNotes.isNotEmpty)
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

                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 10),
                  // Display the Current streak, best streak, average streak(if possible or needed) and
                  Card(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    margin: const EdgeInsets.symmetric(horizontal: 14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 24.0, horizontal: 8),
                      // IntrinsicHeight allows the VerticalDivider to expand to the height of the Text
                      child: IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  "$yearPercentage%",
                                  style: TextStyle(fontSize: 12),
                                ),
                                CircularProgressIndicator(
                                  year2023: false,
                                  value: yearProgressValue,
                                ),
                              ],
                            ),
                            VerticalDivider(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant, // Better contrast than white
                              width: 20,
                              thickness: 1,
                              indent: 4,
                              endIndent: 4,
                            ),
                            Column(
                              children: [
                                Text('Current'),
                                Text(
                                  '$currentStreak days',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            VerticalDivider(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant, // Better contrast than white
                              width: 20,
                              thickness: 1,
                              indent: 4,
                              endIndent: 4,
                            ),
                            Column(
                              children: [
                                Text('Best'),
                                Text(
                                  '$bestStreak days',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            VerticalDivider(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                              width: 20,
                              thickness: 1,
                              indent: 4,
                              endIndent: 4,
                            ),
                            Column(
                              children: [
                                Text('Average'),
                                Text(
                                  '${averageStreak.toInt()} days',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // const Divider(),
                  const SizedBox(height: 10),
                  // Habit Completion Calendar
                  // Calendar for showing completedDates
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 14.0),
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 24.0, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Habit Heatmap",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                              "Since ${DateFormat('MMM, dd, yyyy').format(widget.addedOn)}"),
                          const SizedBox(
                            height: 10,
                          ),
                          HeatMap(
                            colorsets: {
                              1: Theme.of(context).colorScheme.primary
                            },
                            showColorTip: false,
                            showText: false,
                            scrollable: true,
                            colorMode: ColorMode.color,
                            datasets: heatMapDates(),
                            defaultColor: Theme.of(context).colorScheme.surface,
                            // focusedDay: DateTime.now(),
                            // headerStyle: HeaderStyle(formatButtonVisible: false),
                            // calendarStyle:
                            //     const CalendarStyle(isTodayHighlighted: false),
                            // calendarBuilders: CalendarBuilders(
                            //   prioritizedBuilder: (context, date, _) {
                            //     final isDone = _isCompleted(date);
                            //     return Container(
                            //       margin: const EdgeInsets.all(8.0),
                            //       decoration: BoxDecoration(
                            //         color: isDone
                            //             ? Theme.of(context).colorScheme.primary
                            //             : null,
                            //         borderRadius: BorderRadius.circular(12),
                            //       ),
                            //       alignment: Alignment.center,
                            //       child: Text(
                            //         '${date.day}',
                            //         style: TextStyle(
                            //           color: isDone
                            //               ? Theme.of(context)
                            //                   .colorScheme
                            //                   .onPrimary
                            //               : null,
                            //         ),
                            //       ),
                            //     );
                            //   },
                            //   defaultBuilder: (context, date, _) {
                            //     final isDone = _isCompleted(date);
                            //     return Container(
                            //       margin: const EdgeInsets.all(8.0),
                            //       decoration: BoxDecoration(
                            //         color: isDone
                            //             ? Theme.of(context).colorScheme.primary
                            //             : Colors.transparent,
                            //         borderRadius: BorderRadius.circular(12),
                            //       ),
                            //       alignment: Alignment.center,
                            //       child: Text(
                            //         '${date.day}',
                            //         style: TextStyle(
                            //           color: isDone
                            //               ? Theme.of(context)
                            //                   .colorScheme
                            //                   .onPrimary
                            //               : null,
                            //         ),
                            //       ),
                            //     );
                            //   },
                            // ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // const Divider(),
                  const SizedBox(height: 10),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 14.0),
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 24.0, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("This Year's Progress",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 150, // LineChart needs a fixed height
                            child: LineChart(
                              LineChartData(
                                gridData: const FlGridData(show: false),
                                titlesData: FlTitlesData(
                                  topTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  // Show Left Titles for 0-100%
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      getTitlesWidget: (value, meta) => Text(
                                          '${value.toInt()}%',
                                          style: const TextStyle(fontSize: 10)),
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        const months = [
                                          'Jan',
                                          'Feb',
                                          'Mar',
                                          'Apr',
                                          'May',
                                          'Jun',
                                          'Jul',
                                          'Aug',
                                          'Sep',
                                          'Oct',
                                          'Nov',
                                          'Dec'
                                        ];
                                        int index = value.toInt() - 1;
                                        if (index >= 0 && index < 12) {
                                          // Show only every 2nd month to avoid crowding on mobile
                                          return Text(months[index],
                                              style: const TextStyle(
                                                  fontSize: 10));
                                        }
                                        return const SizedBox();
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                minX: 1,
                                maxX: 12,
                                minY: 0,
                                maxY: 100, // Y-axis is now 0% to 100%
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: _generateYearlySpots(),
                                    isCurved: true,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    barWidth: 4,
                                    isStrokeCapRound: true,
                                    dotData: const FlDotData(
                                        show:
                                            false), // Clean look for 12 points
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
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
