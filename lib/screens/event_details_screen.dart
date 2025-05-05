import 'package:audioplayers/audioplayers.dart';
import 'package:bloom/notifications/notification.dart';
import 'package:bloom/screens/event_editing_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventName;
  final String eventNotes;
  final String eventId;
  final DateTime eventStartDateTime;
  final Color? eventColorCode;
  final DateTime? eventEndDateTime;
  final int eventUniqueId;
  const EventDetailsScreen(
      {super.key,
      required this.eventName,
      required this.eventNotes,
      required this.eventId,
      required this.eventStartDateTime,
      this.eventColorCode,
      this.eventEndDateTime,
      required this.eventUniqueId});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  final player = AudioPlayer(playerId: 'events_audio_id');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Event Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Button to mark event as attended
          IconButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('events')
                  .doc(widget.eventId)
                  .update({'isAttended': true});
              // Cancel the scheduled notification
              await NotificationService.cancelNotification(
                  widget.eventUniqueId);
              player.setVolume(1);
              player.play(AssetSource('audio/task_completed.mp3'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Marked as attended!'),
                ),
              );
              Navigator.pop(context);
            },
            icon: const Icon(Icons.task_alt_rounded),
            tooltip: 'Mark as attended',
          ),
          // Button for more options like edit, delete etc
          PopupMenuButton(
            color: Theme.of(context).scaffoldBackgroundColor,
            popUpAnimationStyle:
                AnimationStyle(duration: const Duration(milliseconds: 500)),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => EventEditingScreen(
                          eventId: widget.eventId,
                          eventColorCode: widget.eventColorCode!,
                          eventEndDateTime: widget.eventEndDateTime!,
                          eventName: widget.eventName,
                          eventNotes: widget.eventNotes,
                          eventStartDateTime: widget.eventStartDateTime,
                          eventUniqueId: widget.eventUniqueId,
                        ))),
                child: Text(
                  'Edit',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
              ),
              PopupMenuItem(
                value: 'Delete',
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  // Delete the task from database
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('events')
                      .doc(widget.eventId)
                      .delete();
                  // Show confirmation that task is deleted
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Event deleted succesfully.'),
                    ),
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name of the event
            Text(
              widget.eventName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              height: 12,
            ),
            // Event dates and time
            widget.eventEndDateTime != null &&
                    widget.eventEndDateTime != widget.eventStartDateTime
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "From ${DateFormat('EE dd LLL, yyyy h:mm a').format(widget.eventStartDateTime)}",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      Text(
                        "to ${DateFormat('EE dd LLL, yyyy h:mm a').format(widget.eventEndDateTime!)}",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Text(
                        DateFormat('EEEE dd LLL, yyyy h:mm a')
                            .format(widget.eventStartDateTime),
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
            const Divider(),
            // Event color code
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Color Code',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Container(
                  height: 15,
                  width: 15,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: widget.eventColorCode),
                ),
              ],
            ),
            const Divider(),
            // Event notes
            const Text(
              'Notes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              widget.eventNotes,
            ),
          ],
        ),
      ),
    );
  }
}
