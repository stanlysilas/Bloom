import 'package:audioplayers/audioplayers.dart';
import 'package:bloom/notifications/notification.dart';
import 'package:bloom/screens/event_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class EventsTile extends StatefulWidget {
  final String eventName;
  final String? eventNotes;
  final DateTime eventStartDateTime;
  final DateTime? eventEndDateTime;
  final Color eventColorCode;
  final String eventId;
  final int eventUniqueId;
  final EdgeInsetsGeometry? innerPadding;
  final bool isAttended;
  final BoxDecoration? decoration;
  final BorderRadius? borderRadius;
  const EventsTile(
      {super.key,
      required this.eventName,
      this.eventNotes,
      required this.eventStartDateTime,
      required this.eventId,
      required this.eventColorCode,
      this.eventEndDateTime,
      required this.eventUniqueId,
      this.innerPadding,
      required this.isAttended,
      this.decoration,
      this.borderRadius});

  @override
  State<EventsTile> createState() => _EventsTileState();
}

class _EventsTileState extends State<EventsTile> {
  final player = AudioPlayer(playerId: 'events_audio_id');
  @override
  Widget build(BuildContext context) {
    return Slidable(
      startActionPane: ActionPane(
          motion: const ScrollMotion(),
          dragDismissible: true,
          children: [
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: InkWell(
                onTap: () async {
                  // Delete from firebase
                  final user = FirebaseAuth.instance.currentUser;
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user?.uid)
                      .collection('events')
                      .doc(widget.eventId)
                      .update({
                    'isAttended': true,
                  });
                  // Cancel the scheduled notification
                  await NotificationService.cancelNotification(
                      widget.eventUniqueId);
                  player.setVolume(1);
                  player.play(AssetSource('audio/task_completed.mp3'));
                  if (widget.isAttended) {
                    // Generate a date from the task date
                    final eventCompletedDate = DateTime(
                        widget.eventStartDateTime.year,
                        widget.eventStartDateTime.month,
                        widget.eventStartDateTime.day,
                        0,
                        0,
                        0);
                    // Save the reference to only the date of this task in a streaks collections in users collection
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user?.uid)
                        .collection('streaks')
                        .doc('streaks')
                        .set({
                      'eventsCompletedDates':
                          FieldValue.arrayUnion([eventCompletedDate]),
                    }, SetOptions(merge: true));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: widget.eventColorCode,
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.event_available_rounded),
                ),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
          ]),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        dragDismissible: true,
        children: [
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: InkWell(
              onTap: () async {
                // Delete from firebase
                final user = FirebaseAuth.instance.currentUser;
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .collection('events')
                    .doc(widget.eventId)
                    .delete();
                // Cancel the scheduled notification
                await NotificationService.cancelNotification(
                    widget.eventUniqueId);
                // Show deleted confirmation
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
                        const Text('Deleted: '),
                        Text(
                          widget.eventName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
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
                child: Icon(Icons.delete_rounded),
              ),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
        ],
      ),
      child: Material(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(0),
        child: InkWell(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(0),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EventDetailsScreen(
                eventId: widget.eventId,
                eventName: widget.eventName,
                eventNotes: widget.eventNotes ?? '',
                eventStartDateTime: widget.eventStartDateTime,
                eventEndDateTime: widget.eventEndDateTime,
                eventColorCode: widget.eventColorCode,
                eventUniqueId: widget.eventUniqueId,
                isAttended: widget.isAttended,
              ),
            ),
          ),
          child: Container(
            padding: widget.innerPadding ?? const EdgeInsets.all(0),
            decoration: widget.decoration ?? BoxDecoration(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 6,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: widget.eventColorCode,
                      borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.calendar_month_rounded),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        widget.eventName,
                        maxLines: 1,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (widget.eventEndDateTime!.isBefore(DateTime.now()) &&
                          widget.isAttended == false)
                        const Text(
                          'Overdue',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w500),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    widget.eventEndDateTime!.isBefore(DateTime.now()) &&
                            widget.isAttended == false
                        ? Text(
                            DateFormat.MEd().format(widget.eventEndDateTime!),
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, color: Colors.red),
                            overflow: TextOverflow.ellipsis,
                          )
                        : Text(
                            DateFormat.MEd().format(widget.eventStartDateTime),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                    widget.eventEndDateTime!.isBefore(DateTime.now()) &&
                            widget.isAttended == false
                        ? Text(
                            DateFormat('h:mm a')
                                .format(widget.eventEndDateTime!),
                            style: const TextStyle(color: Colors.red),
                            overflow: TextOverflow.ellipsis,
                          )
                        : Text(
                            DateFormat('h:mm a')
                                .format(widget.eventStartDateTime),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey),
                          ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    ).animate().fade(delay: const Duration(milliseconds: 50));
  }
}
