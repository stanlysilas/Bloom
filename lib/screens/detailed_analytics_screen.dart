import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailedAnalyticsScreen extends StatefulWidget {
  final Map<DateTime, int>
      completedTasksPerDay; // Store completion counts for each day

  const DetailedAnalyticsScreen(
      {super.key, required this.completedTasksPerDay});

  @override
  State<DetailedAnalyticsScreen> createState() =>
      _DetailedAnalyticsScreenState();
}

class _DetailedAnalyticsScreenState extends State<DetailedAnalyticsScreen> {
  late List<DateTime> weekDates; // Store dates for the current week

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
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Task Completion This Week",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(
                    border: Border(
                      top: BorderSide.none,
                      right: BorderSide.none,
                      left: BorderSide(color: Theme.of(context).primaryColor),
                      bottom: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          DateTime date = weekDates[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('E')
                                  .format(date), // Show Mon, Tue, etc.
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  groupsSpace: 12,
                  barGroups: weekDates.asMap().entries.map((entry) {
                    int index = entry.key;
                    DateTime date = entry.value;
                    int completedTasks = widget.completedTasksPerDay[date] ??
                        0; // Get task count

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: completedTasks.toDouble(),
                          width: 18,
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
