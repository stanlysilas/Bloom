import 'package:bloom/features/goals/habits/widgets/habit_tile.dart';
import 'package:bloom/features/objects/shared/widgets/filter_strip.dart';
import 'package:bloom/models/habit_model.dart';
import 'package:flutter/material.dart';

class Habitstabview extends StatefulWidget {
  final List<HabitModel> habits;
  const Habitstabview({super.key, required this.habits});

  @override
  State<Habitstabview> createState() => _HabitstabviewState();
}

class _HabitstabviewState extends State<Habitstabview> {
  String sortValue = 'all';

  final habitFilters = [
    const FilterOption(
      value: 'all',
      title: 'All',
      subtitle: 'Show all habits',
    ),
    const FilterOption(
      value: 'today',
      title: 'Today',
      subtitle: 'Show habits for today',
    ),
    const FilterOption(
      value: 'oldest',
      title: 'Oldest',
      subtitle: 'Sort from oldest to recent',
    ),
  ];

  List<HabitModel> get filteredHabits {
    var list = [...widget.habits];
    final now = DateTime.now();

    switch (sortValue) {
      case 'today':
        list = list.where((h) {
          final d = h.dateTime;
          return d.year == now.year && d.month == now.month && d.day == now.day;
        }).toList();
        break;

      case 'oldest':
        list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        return list;

      case 'all':
      default:
        return list;
    }

    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final habits = filteredHabits;

    return Column(
      children: [
        FilterStrip(
            sortValue: sortValue,
            onChanged: (value) => setState(() => sortValue = value),
            filters: habitFilters),
        Expanded(
          child: habits.isEmpty
              ? Center(
                  child: Column(
                    children: [
                      Image(
                        height: 250,
                        width: 250,
                        image: AssetImage(
                            'assets/images/habitsEmptyBackground.png'),
                      ),
                      Text(
                        'You have no habits',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        'Click on the + icon to create and nurture a new good habit',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 14,
                      )
                    ],
                  ),
                )
              : ListView.builder(
                  key: ValueKey(sortValue),
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final habitModel = habits[index];

                    return HabitTile(
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      innerPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      habitModel: habitModel,
                    );
                  },
                ),
        ),
        const SizedBox(height: 64)
      ],
    );
  }
}
