import 'package:bloom/core/utils/bloom_snackbars.dart';
import 'package:bloom/core/widgets/actionobjects/date_time_section.dart';
import 'package:bloom/core/widgets/actionobjects/name_notes_section.dart';
import 'package:bloom/features/goals/tasks/widgets/recurring_tasks_section.dart';
import 'package:bloom/services/firebase/notification.dart';
import 'package:flutter/material.dart';
import 'package:bloom/services/firebase/action_creation_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final nameController = TextEditingController();
  final notesController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  bool isRecurring = false;
  List<int> recurringDays = [];

  int priorityLevel = 3;
  List<String> groups = [];

  DateTime get finalDateTime {
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  void toggleDay(int index) {
    setState(() {
      if (recurringDays.contains(index)) {
        recurringDays.remove(index);
      } else {
        recurringDays.add(index);
      }
      recurringDays.sort();
    });
  }

  Future<void> submit() async {
    if (nameController.text.trim().isEmpty) {
      BloomSnackBars()
          .showGenericErrorSnackBar(context, 'Task name is required');
      return;
    }

    final uniqueId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await ActionCreationService.createTask(
      name: nameController.text.trim(),
      description: notesController.text.trim(),
      dateTime: finalDateTime,
      groups: groups,
      priorityLevel: priorityLevel,
      uniqueId: uniqueId,
    );

    await NotificationService.scheduleTaskNotification(
      uniqueId: uniqueId,
      title: nameController.text.trim(),
      body: notesController.text.trim(),
      scheduledDate: finalDateTime,
      importance: Importance.high,
      priority: Priority.high,
      isRecurring: isRecurring,
      recurringDays: recurringDays,
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    nameController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('New Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            NameNotesSection(
              nameController: nameController,
              notesController: notesController,
            ),
            const SizedBox(height: 20),
            DateTimeSection(
              date: selectedDate,
              time: selectedTime,
              onPickDate: pickDate,
              onPickTime: pickTime,
            ),
            const SizedBox(height: 20),
            _PrioritySection(
              priorityLevel: priorityLevel,
              onChanged: (val) {
                setState(() => priorityLevel = val);
              },
            ),
            const SizedBox(height: 20),
            RecurringTaskSection(
              isRecurring: isRecurring,
              selectedDays: recurringDays,
              onToggle: (val) => setState(() => isRecurring = val),
              onDayToggle: toggleDay,
            ),
            const SizedBox(height: 30),
            InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: submit,
              child: Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text('Create task',
                      style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onPrimary)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrioritySection extends StatelessWidget {
  final int priorityLevel;
  final ValueChanged<int> onChanged;

  const _PrioritySection({
    required this.priorityLevel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Text('Priority'),
          const Spacer(),
          DropdownButton<int>(
            value: priorityLevel,
            elevation: 0,
            underline: const SizedBox(),
            borderRadius: BorderRadius.circular(24),
            items: const [
              DropdownMenuItem(value: 1, child: Text('High')),
              DropdownMenuItem(value: 2, child: Text('Medium')),
              DropdownMenuItem(value: 3, child: Text('Low')),
            ],
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
          ),
        ],
      ),
    );
  }
}
