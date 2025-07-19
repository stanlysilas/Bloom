import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:intl/intl.dart';

class DetailedAnalyticsScreen extends StatefulWidget {
  final Map<DateTime, int> completedTasksPerDay;
  final Map<DateTime, int> completedEventsByDate;
  final Map<DateTime, int> completedHabitsByDate;
  final Map<DateTime, int> completedEntriesByDate;
  final Map<DateTime, int> allCompletedByDate;

  const DetailedAnalyticsScreen(
      {super.key,
      required this.completedTasksPerDay,
      required this.completedEventsByDate,
      required this.completedHabitsByDate,
      required this.completedEntriesByDate,
      required this.allCompletedByDate});

  @override
  State<DetailedAnalyticsScreen> createState() =>
      _DetailedAnalyticsScreenState();
}

class _DetailedAnalyticsScreenState extends State<DetailedAnalyticsScreen> {
  late List<DateTime> weekDates;
  String viewType = 'heatmap';

  @override
  void initState() {
    super.initState();
    weekDates = _getCurrentWeekDates();
  }

  // Get current week's dates (Monday - Sunday)
  List<DateTime> _getCurrentWeekDates() {
    DateTime now = DateTime.now();
    int currentWeekday = now.weekday;
    DateTime monday =
        now.subtract(Duration(days: currentWeekday - 1)); // Get Monday

    return List.generate(
        7, (index) => monday.add(Duration(days: index))); // Generate 7 days
  }

  // State update method
  void stateUpdate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RawChip(
                  backgroundColor: Theme.of(context).primaryColor,
                  labelStyle: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                  side: BorderSide.none,
                  avatar: Icon(Icons.filter_alt_rounded),
                  iconTheme: IconThemeData(
                      color: Theme.of(context).textTheme.bodyMedium?.color),
                  label: Text('Heatmap'),
                  onPressed: () {
                    // Open a dialog to change the analytics view
                    showAdaptiveDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog.adaptive(
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            title: Text('Select a view'),
                            titleTextStyle: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                                fontSize: 24,
                                fontWeight: FontWeight.w500),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 0, vertical: 8),
                            content: SizedBox(
                              height: 150,
                              child: Column(
                                children: [
                                  // Display the RadioButtons to select a single view
                                  ListTile(
                                    dense: true,
                                    minVerticalPadding: 0,
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 4),
                                    leading: Radio.adaptive(
                                        value: 'heatmap',
                                        groupValue: viewType,
                                        onChanged: (String? view) {
                                          setState(() {
                                            viewType = view!;
                                          });
                                          // stateUpdate();
                                        }),
                                    horizontalTitleGap: 0,
                                    title: Text(
                                      'Heatmap',
                                      textAlign: TextAlign.start,
                                    ),
                                    subtitle: Text(
                                        'Show a Heatmap of all your objects'),
                                    titleTextStyle: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color),
                                    subtitleTextStyle:
                                        TextStyle(color: Colors.grey),
                                    onTap: () {
                                      setState(() {
                                        viewType = 'heatmap';
                                      });
                                      Navigator.of(context).pop();
                                      stateUpdate();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      viewType = 'heatmap';
                                    });
                                    Navigator.of(context).pop();
                                    stateUpdate();
                                  },
                                  child: Text('Close'))
                            ],
                          );
                        });
                  },
                ),
                const SizedBox(height: 10),
                const Text(
                  "All Objects",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                // Heatmap for task completions
                HeatMap(
                  datasets: widget.allCompletedByDate,
                  colorMode: ColorMode.opacity,
                  showText: false,
                  scrollable: true,
                  showColorTip: false,
                  defaultColor: Theme.of(context).primaryColorDark,
                  colorsets: {
                    1: Theme.of(context).primaryColor,
                  },
                  onClick: (value) {
                    if (widget.completedTasksPerDay.containsKey(value)) {
                      final taskCount = widget.completedTasksPerDay[value];
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          margin: const EdgeInsets.all(6),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          content: Text(
                              'Objects added on ${DateFormat('MMM dd, yyyy').format(value)}: $taskCount'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            margin: const EdgeInsets.all(6),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            content: Text('No objects added on this day.')),
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                const Text(
                  "Tasks",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                // Heatmap for task completions
                HeatMap(
                  datasets: widget.completedTasksPerDay,
                  colorMode: ColorMode.opacity,
                  showText: false,
                  scrollable: true,
                  showColorTip: false,
                  defaultColor: Theme.of(context).primaryColorDark,
                  colorsets: {
                    1: Theme.of(context).primaryColor,
                  },
                  onClick: (value) {
                    if (widget.completedTasksPerDay.containsKey(value)) {
                      final taskCount = widget.completedTasksPerDay[value];
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          margin: const EdgeInsets.all(6),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          content: Text(
                              'Tasks completed on ${DateFormat('MMM dd, yyyy').format(value)}: $taskCount'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            margin: const EdgeInsets.all(6),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            content: Text('No tasks completed on this day.')),
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                const Text(
                  "Events",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                // Heatmap for task completions
                HeatMap(
                  datasets: widget.completedEventsByDate,
                  colorMode: ColorMode.opacity,
                  showText: false,
                  scrollable: true,
                  showColorTip: false,
                  defaultColor: Theme.of(context).primaryColorDark,
                  colorsets: {
                    1: Theme.of(context).primaryColor,
                  },
                  onClick: (value) {
                    if (widget.completedTasksPerDay.containsKey(value)) {
                      final taskCount = widget.completedTasksPerDay[value];
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          margin: const EdgeInsets.all(6),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          content: Text(
                              'Events attended on ${DateFormat('MMM dd, yyyy').format(value)}: $taskCount'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            margin: const EdgeInsets.all(6),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            content: Text('No events attended on this day.')),
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                const Text(
                  "Habits",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                // Heatmap for task completions
                HeatMap(
                  datasets: widget.completedHabitsByDate,
                  colorMode: ColorMode.opacity,
                  showText: false,
                  scrollable: true,
                  showColorTip: false,
                  defaultColor: Theme.of(context).primaryColorDark,
                  colorsets: {
                    1: Theme.of(context).primaryColor,
                  },
                  onClick: (value) {
                    if (widget.completedTasksPerDay.containsKey(value)) {
                      final taskCount = widget.completedTasksPerDay[value];
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          margin: const EdgeInsets.all(6),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          content: Text(
                              'Habits added on ${DateFormat('MMM dd, yyyy').format(value)}: $taskCount'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            margin: const EdgeInsets.all(6),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            content: Text('No habits added on this day.')),
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                const Text(
                  "Entries",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                // Heatmap for task completions
                HeatMap(
                  datasets: widget.completedEntriesByDate,
                  colorMode: ColorMode.opacity,
                  showText: false,
                  scrollable: true,
                  showColorTip: false,
                  defaultColor: Theme.of(context).primaryColorDark,
                  colorsets: {
                    1: Theme.of(context).primaryColor,
                  },
                  onClick: (value) {
                    if (widget.completedTasksPerDay.containsKey(value)) {
                      final taskCount = widget.completedTasksPerDay[value];
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          margin: const EdgeInsets.all(6),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          content: Text(
                              'Entries added on ${DateFormat('MMM dd, yyyy').format(value)}: $taskCount'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            margin: const EdgeInsets.all(6),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            content: Text('No entries added on this day.')),
                      );
                    }
                  },
                ),
                // SizedBox(
                //   height: 250,
                //   child: BarChart(
                //     BarChartData(
                //       borderData: FlBorderData(
                //         border: Border(
                //           top: BorderSide.none,
                //           right: BorderSide.none,
                //           left: BorderSide(color: Theme.of(context).primaryColor),
                //           bottom: BorderSide(color: Theme.of(context).primaryColor),
                //         ),
                //       ),
                //       titlesData: FlTitlesData(
                //         leftTitles: const AxisTitles(
                //           sideTitles:
                //               SideTitles(showTitles: true, reservedSize: 40),
                //         ),
                //         bottomTitles: AxisTitles(
                //           sideTitles: SideTitles(
                //             showTitles: true,
                //             getTitlesWidget: (value, meta) {
                //               DateTime date = weekDates[value.toInt()];
                //               return Padding(
                //                 padding: const EdgeInsets.only(top: 8.0),
                //                 child: Text(
                //                   DateFormat('E')
                //                       .format(date), // Show Mon, Tue, etc.
                //                   style: const TextStyle(fontSize: 12),
                //                 ),
                //               );
                //             },
                //           ),
                //         ),
                //         topTitles:
                //             const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                //         rightTitles:
                //             const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                //       ),
                //       groupsSpace: 12,
                //       barGroups: weekDates.asMap().entries.map((entry) {
                //         int index = entry.key;
                //         DateTime date = entry.value;
                //         int completedTasks = widget.completedTasksPerDay[date] ??
                //             0; // Get task count

                //         return BarChartGroupData(
                //           x: index,
                //           barRods: [
                //             BarChartRodData(
                //               toY: completedTasks.toDouble(),
                //               width: 18,
                //               color: Theme.of(context).primaryColor,
                //               borderRadius: BorderRadius.circular(4),
                //             ),
                //           ],
                //         );
                //       }).toList(),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
