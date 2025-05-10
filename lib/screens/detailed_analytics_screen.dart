import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:intl/intl.dart';

class DetailedAnalyticsScreen extends StatefulWidget {
  final Map<DateTime, int> completedTasksPerDay;

  const DetailedAnalyticsScreen(
      {super.key, required this.completedTasksPerDay});

  @override
  State<DetailedAnalyticsScreen> createState() =>
      _DetailedAnalyticsScreenState();
}

class _DetailedAnalyticsScreenState extends State<DetailedAnalyticsScreen> {
  late List<DateTime> weekDates;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detailed Analytics',
            style: TextStyle(fontWeight: FontWeight.w500)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Task Completion",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Heatmap for task completions
            HeatMap(
              datasets: widget.completedTasksPerDay,
              colorMode: ColorMode.opacity,
              showText: false,
              showColorTip: false,
              scrollable: true,
              colorsets: {
                1: Theme.of(context).primaryColor,
              },
              onClick: (value) {
                if (widget.completedTasksPerDay.containsKey(value)) {
                  final taskCount = widget.completedTasksPerDay[value];
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Tasks completed on ${DateFormat('MMM dd, yyyy').format(value)}: $taskCount'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('No tasks completed on this day.')),
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
    );
  }
}
