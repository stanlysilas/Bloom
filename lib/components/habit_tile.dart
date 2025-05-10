import 'package:bloom/notifications/notification.dart';
import 'package:bloom/screens/habits_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
// import 'package:intl/intl.dart';

class HabitTile extends StatefulWidget {
  final String habitId;
  final String habitName;
  final String habitNotes;
  final List habitGroups;
  final DateTime habitDateTime;
  final List daysOfWeek;
  final List completedDaysOfWeek;
  final DateTime addedOn;
  final int habitUniqueId;
  final List completedDates;
  final EdgeInsetsGeometry? innerPadding;
  const HabitTile(
      {super.key,
      required this.habitId,
      required this.habitName,
      required this.habitNotes,
      required this.habitDateTime,
      required this.habitGroups,
      required this.daysOfWeek,
      required this.completedDaysOfWeek,
      required this.addedOn,
      required this.habitUniqueId,
      this.innerPadding,
      required this.completedDates});

  @override
  State<HabitTile> createState() => _HabitTileState();
}

class _HabitTileState extends State<HabitTile> {
  // Reuired variables
  final user = FirebaseAuth.instance.currentUser;
  final List<String> daysOfWeekString = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  void updateCompletedDaysOfWeek(int value) {
    final firestore = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('habits')
        .doc(widget.habitId);

    // Step 1: Get the date of the target weekday in current week
    DateTime now = DateTime.now();
    int currentWeekday = now.weekday % 7; // Convert Monday=1...Sunday=7 → 0-6
    DateTime targetDate = now.subtract(Duration(days: currentWeekday - value));

    // Step 2: Format the date
    String dateKey = DateFormat('yyyy-MM-dd').format(targetDate);

    // Step 3: Check if already completed
    bool alreadyCompleted = widget.completedDaysOfWeek.contains(value);

    // Step 4: Update Firestore
    firestore.update({
      'completedDaysOfWeek': alreadyCompleted
          ? FieldValue.arrayRemove([value])
          : FieldValue.arrayUnion([value]),
      'completedDates': alreadyCompleted
          ? FieldValue.arrayRemove([dateKey])
          : FieldValue.arrayUnion([dateKey]),
    });

    // Step 5: Update local state (if needed)
    setState(() {
      if (alreadyCompleted) {
        widget.completedDaysOfWeek.remove(value);
      } else {
        widget.completedDaysOfWeek.add(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: InkWell(
              onTap: () async {
                final user = FirebaseAuth.instance.currentUser;
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .collection('habits')
                    .doc(widget.habitId)
                    .delete();
                NotificationService.cancelNotification(widget.habitUniqueId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    margin: const EdgeInsets.all(6),
                    behavior: SnackBarBehavior.floating,
                    showCloseIcon: true,
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    content: Wrap(
                      children: [
                        Text(
                          'Deleted: ',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color),
                        ),
                        Text(
                          widget.habitName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color),
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(8)),
                child: Icon(
                  Iconsax.trash,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Navigate to habits screen or show a modal bottom sheet
          showModalBottomSheet(
              context: context,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              showDragHandle: true,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (context) {
                return HabitsDetailsScreen(
                  habitName: widget.habitName,
                  habitNotes: widget.habitNotes,
                  habitDateTime: widget.habitDateTime,
                  habitGroups: widget.habitGroups,
                  habitId: widget.habitId,
                  habitUniqueId: widget.habitUniqueId,
                  addedOn: widget.addedOn,
                  daysOfWeek: widget.daysOfWeek,
                  completedDaysOfWeek: widget.completedDaysOfWeek,
                  completedDates: widget.completedDates,
                );
              });
        },
        child: Padding(
          padding: widget.innerPadding ?? const EdgeInsets.all(0),
          child: Row(
            children: [
              // Icon or emoji of the habit
              Container(
                padding: const EdgeInsets.all(10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColorLight),
                child: const Icon(Icons.repeat_rounded),
              ),
              const SizedBox(
                width: 8,
              ),
              // Name and notes or description of the habit
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.habitName,
                      style: const TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.habitNotes != '')
                      Text(
                        widget.habitNotes,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    // Text(
                    //   "${DateFormat.MEd().format(widget.habitDateTime)}, ${DateFormat('h:mm a').format(widget.habitDateTime)}",
                    //   style: const TextStyle(fontSize: 14, color: Colors.grey),
                    // ),
                  ],
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              // Dates marked for the habit
              ...List.generate(7, (value) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(5),
                    onTap: () async {
                      // Update the completedDaysOfWeek in database
                      updateCompletedDaysOfWeek(value);
                      // Update the completedDaysOfWeek locally when tapped on the particular day button
                      setState(() {
                        if (widget.completedDaysOfWeek.contains(value)) {
                          widget.completedDaysOfWeek.remove(value);
                        } else {
                          widget.completedDaysOfWeek.add(value);
                        }
                      });
                    },
                    child: Container(
                      height: 25,
                      width: 25,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: widget.daysOfWeek.contains(value)
                              ? widget.completedDaysOfWeek.contains(value)
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).primaryColorLight
                              : Colors.transparent),
                      child: Text(
                        widget.daysOfWeek.contains(value)
                            ? daysOfWeekString[value]
                            : '',
                        style: TextStyle(
                            color: widget.daysOfWeek.contains(value)
                                ? widget.completedDaysOfWeek.contains(value)
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                    : Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                : Colors.transparent),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
