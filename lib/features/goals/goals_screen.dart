import 'package:bloom/features/goals/events/screens/eventstabview.dart';
import 'package:bloom/features/goals/habits/screens/habitstabview.dart';
import 'package:bloom/features/goals/tasks/screens/taskstabview.dart';
import 'package:bloom/models/action_object_model.dart';
import 'package:bloom/models/event_model.dart';
import 'package:bloom/models/habit_model.dart';
import 'package:bloom/models/task_model.dart';
import 'package:bloom/services/firebase/action_object_service.dart';
import 'package:flutter/material.dart';

class GoalsScreen extends StatefulWidget {
  final int? tabIndex;
  const GoalsScreen({super.key, this.tabIndex});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen>
    with TickerProviderStateMixin {
  late Stream<List<ActionObjectModel>> actionObjectStream;
  final actionObjectService = ActionObjectService();
  late final TabController tabController;
  late int tabIndex;

  @override
  void initState() {
    super.initState();
    actionObjectStream = actionObjectService.fetchActionObjects();
    tabController = TabController(
        initialIndex: widget.tabIndex ?? 0, length: 3, vsync: this);
    setState(() {
      tabIndex = tabController.index;
    });
  }

  String _resolveAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Tasks';
      case 1:
        return 'Habits';
      case 2:
        return 'Events';
      default:
        return 'Goals';
    }
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _resolveAppBarTitle(tabIndex),
          style: TextStyle(
              fontFamily: 'ClashGrotesk', fontWeight: FontWeight.w500),
        ),
        bottom: TabBar(
            controller: tabController,
            onTap: (value) {
              setState(() {
                tabIndex = value;
              });
            },
            tabs: const [
              Tab(text: 'Tasks'),
              Tab(text: 'Habits'),
              Tab(text: 'Events')
            ]),
      ),
      body: StreamBuilder<List<ActionObjectModel>>(
          stream: actionObjectStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error.toString()}');
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!;

            final tasks = data.whereType<TaskModel>().toList();
            final habits = data.whereType<HabitModel>().toList();
            final events = data.whereType<EventModel>().toList();

            return TabBarView(
              controller: tabController,
              children: [
                Taskstabview(tasks: tasks),
                Habitstabview(habits: habits),
                SchedulesScreen(events: events),
              ],
            );
          }),
    );
  }
}
