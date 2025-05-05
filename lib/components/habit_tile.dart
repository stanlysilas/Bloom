import 'package:bloom/notifications/notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:iconsax/iconsax.dart';
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
      this.innerPadding});

  @override
  State<HabitTile> createState() => _HabitTileState();
}

class _HabitTileState extends State<HabitTile> {
  // Reuired variables
  final user = FirebaseAuth.instance.currentUser;
  final List<String> daysOfWeekString = [
    'S',
    'M',
    'T',
    'W',
    'T',
    'F',
    'S'
  ];

  // Method to update the completedDaysOfWeek accordingly
  updateCompletedDaysOfWeek(int value) {
    final firestore = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('habits')
        .doc(widget.habitId);
    // Check if it is already added or not and then update accordingly
    if (widget.completedDaysOfWeek.contains(value)) {
      // If its already added
      firestore.update({
        'completedDaysOfWeek': FieldValue.arrayRemove([
          value
        ]), // Remove from the completedDaysOfWeek int list field the 'value'
      });
    } else {
      // If its not already added
      firestore.update({
        'completedDaysOfWeek': FieldValue.arrayUnion([
          value
        ]), // Add to the completedDaysOfWeek int list field the 'value'
      });
    }
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
              builder: (context) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 6,
                      ),
                      const Text(
                        'Habit details',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        widget.habitName,
                        overflow: TextOverflow.clip,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        widget.habitNotes,
                        overflow: TextOverflow.clip,
                      )
                    ],
                  ),
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
                    color: Theme.of(context).primaryColor.withAlpha(100)),
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
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(5),
                    onTap: () async {
                      // Update the completedDaysOfWeek in database
                      await updateCompletedDaysOfWeek(value);
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
                        // style: TextStyle(
                        //     color: widget.daysOfWeek.contains(value)
                        //         ? Theme.of(context).textTheme.bodyMedium?.color
                        //         : Theme.of(context).scaffoldBackgroundColor),
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
