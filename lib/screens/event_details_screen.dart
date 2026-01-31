import 'package:audioplayers/audioplayers.dart';
import 'package:bloom/audio_services/audio_manager.dart';
import 'package:bloom/components/delete_confirmation_dialog.dart';
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
  final bool isAttended;
  final IconData? appBarLeading;
  const EventDetailsScreen(
      {super.key,
      required this.eventName,
      required this.eventNotes,
      required this.eventId,
      required this.eventStartDateTime,
      this.eventColorCode,
      this.eventEndDateTime,
      required this.eventUniqueId,
      this.appBarLeading,
      required this.isAttended});

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
        leading: IconButton(
            style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.surfaceContainer)),
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(widget.appBarLeading ?? Icons.arrow_back,
                color: Colors.grey)),
        title: const Text('Details',
            style: TextStyle(
                fontFamily: 'ClashGrotesk', fontWeight: FontWeight.w500)),
        actions: [
          // Button to mark event as attended
          IconButton(
            style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.surfaceContainer)),
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
              // Play completion Audio
              AudioManager().playTaskCompleted();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  margin: const EdgeInsets.all(6),
                  behavior: SnackBarBehavior.floating,
                  showCloseIcon: true,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  content: Text('Marked as attended!'),
                ),
              );
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
                    .doc(userId)
                    .collection('streaks')
                    .doc('streaks')
                    .set({
                  'eventsCompletedDates':
                      FieldValue.arrayUnion([eventCompletedDate]),
                }, SetOptions(merge: true));
              }
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.event_available_rounded,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            tooltip: 'Mark as attended',
          ),
          // Button for more options like edit, delete etc
          PopupMenuButton(
            iconColor: Colors.grey,
            style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.surfaceContainer)),
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
                child: Text('Edit'),
              ),
              PopupMenuItem(
                value: 'Delete',
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  showAdaptiveDialog(
                      context: context,
                      builder: (context) {
                        return DeleteConfirmationDialog(
                            onPressed: () async {
                              // Delete the task from database
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .collection('events')
                                  .doc(widget.eventId)
                                  .delete();
                              // Show confirmation that task is deleted
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  margin: const EdgeInsets.all(6),
                                  behavior: SnackBarBehavior.floating,
                                  showCloseIcon: true,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  content: Text('Event deleted succesfully.'),
                                ),
                              );
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            objectName: widget.eventName);
                      });
                },
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name of the event
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Text(
              widget.eventName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          // Event dates and time
          widget.eventEndDateTime != null &&
                  widget.eventEndDateTime != widget.eventStartDateTime
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Column(
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
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('EEEE dd LLL, yyyy h:mm a')
                            .format(widget.eventStartDateTime),
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
          const Divider(),
          // Event color code
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Row(
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
          ),
          const Divider(),
          // Event notes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: const Text(
              'Notes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Text(
              widget.eventNotes,
            ),
          ),
        ],
      ),
    );
  }
}
