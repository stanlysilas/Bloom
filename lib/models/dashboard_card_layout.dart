import 'package:bloom/features/objects/shared/widgets/objects_tile.dart';
import 'package:bloom/features/goals/events/widgets/events_tile.dart';
import 'package:bloom/features/goals/habits/widgets/habit_tile.dart';
import 'package:bloom/features/goals/tasks/widgets/tasktile.dart';
import 'package:bloom/models/bloom_object_model.dart';
import 'package:bloom/models/event_model.dart';
import 'package:bloom/models/habit_model.dart';
import 'package:bloom/models/task_model.dart';
import 'package:bloom/services/firebase/data_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'dart:async';

class DashboardCardLayout extends StatefulWidget {
  final DateTime focusedDay;
  const DashboardCardLayout({
    super.key,
    required this.focusedDay,
  });

  @override
  State<DashboardCardLayout> createState() => _DashboardCardLayoutState();
}

class _DashboardCardLayoutState extends State<DashboardCardLayout> {
  final user = FirebaseAuth.instance.currentUser;
  late Stream<List<BloomObjectModel>> combinedStream;
  final dataService = DataService();
  BorderRadius borderRadius = BorderRadius.all(Radius.circular(0));

  @override
  void initState() {
    super.initState();
    combinedStream = dataService.dashboardObjectsStream(widget.focusedDay);
  }

  Widget _buildItem(BloomObjectModel item) {
    if (item is TaskModel) {
      return TaskTile(
        innerPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        taskModel: item,
      );
    }

    if (item is HabitModel) {
      return HabitTile(
        innerPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        habitModel: item,
      );
    }

    if (item is EventModel) {
      return EventsTile(
        innerPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        eventModel: item,
      );
    }

    return ObjectsTile(
      innerPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      bloomObject: item,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BloomObjectModel>>(
      stream: combinedStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            children: [
              ...List.generate(3, growable: false, (index) {
                return Skeletonizer(
                  enabled: true,
                  containersColor: Theme.of(context).primaryColorLight,
                  child: ListTile(
                    leading: Icon(Icons.abc),
                    title: Text(
                      'So this is the text of the title of the object here...',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                    ),
                    subtitle: Text(
                      'So this is the text of the subtitle of the object here...',
                      maxLines: 1,
                    ),
                    trailing: Text('End'),
                  ),
                );
              }),
            ],
          );
        }

        if (snapshot.hasError) {
          return Text('Failed to load dashboard data.');
        }

        final items = snapshot.data!;

        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: items.length > 10 ? 10 : items.length,
          itemBuilder: (context, index) {
            final item = items[index];

            return Padding(
              padding: EdgeInsets.only(
                top: index == 0 ? 8 : 4,
                bottom: index == items.length - 1 ? 8 : 4,
              ),
              child: KeyedSubtree(
                key: ValueKey(item.objectId),
                child: _buildItem(item),
              ),
            );
          },
        );
      },
    );
  }
}
