import 'package:bloom/features/goals/events/widgets/events_tile.dart';
import 'package:bloom/features/objects/shared/widgets/filter_strip.dart';
import 'package:bloom/models/event_model.dart';
import 'package:flutter/material.dart';

class SchedulesScreen extends StatefulWidget {
  final List<EventModel> events;
  const SchedulesScreen({super.key, required this.events});

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  String sortValue = 'not_attended';

  final eventFilters = [
    const FilterOption(
      value: 'not_attended',
      title: 'Not Attended',
      subtitle: 'Show not attended events',
    ),
    const FilterOption(
      value: 'all',
      title: 'All',
      subtitle: 'Show all events',
    ),
    const FilterOption(
      value: 'attended',
      title: 'Attended',
      subtitle: 'Show attended events',
    ),
    const FilterOption(
      value: 'today',
      title: 'Today',
      subtitle: 'Show events for today',
    ),
    const FilterOption(
      value: 'oldest',
      title: 'Oldest',
      subtitle: 'Sort from oldest to recent',
    ),
  ];

  List<EventModel> get filteredEvents {
    var list = [...widget.events];
    final now = DateTime.now();

    switch (sortValue) {
      case 'today':
        list = list.where((e) {
          final d = e.dateTime;
          return d.year == now.year && d.month == now.month && d.day == now.day;
        }).toList();
        break;

      case 'attended':
        list = list.where((e) => e.isCompleted == true).toList();
        break;

      case 'oldest':
        list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        return list;

      case 'all':
        break;

      case 'not_attended':
      default:
        list = list.where((e) => e.isCompleted == false).toList();
        break;
    }

    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final events = filteredEvents;

    return Column(
      children: [
        FilterStrip(
            sortValue: sortValue,
            onChanged: (value) => setState(() => sortValue = value),
            filters: eventFilters),
        Expanded(
          child: events.isEmpty
              ? const Center(
                  child: Column(
                    children: [
                      Image(
                        height: 250,
                        width: 250,
                        image: AssetImage(
                            'assets/images/allCompletedBackground.png'),
                      ),
                      Text(
                        'Finally! Attended your events',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        'Take your most deserved holiday now',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  key: ValueKey(sortValue),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final eventModel = events[index];

                    return EventsTile(
                      innerPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      eventModel: eventModel,
                    );
                  }),
        ),
        const SizedBox(height: 64)
      ],
    );
  }
}
