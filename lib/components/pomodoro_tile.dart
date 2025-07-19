import 'package:bloom/notifications/notification.dart';
import 'package:bloom/screens/pomodoro_timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class PomodoroTile extends StatefulWidget {
  final String pomodoroName;
  final DateTime pomodoroDateTime;
  final int pomodoroDuration;
  final int longBreakDuration;
  final int shortBreakDuration;
  final String pomodoroId;
  final int pomodoroUniqueId;
  final PomodoroTimerProvider pomodoroTimerProvider;
  final EdgeInsetsGeometry? innerPadding;
  const PomodoroTile({
    super.key,
    this.innerPadding,
    required this.pomodoroName,
    required this.pomodoroDateTime,
    required this.pomodoroDuration,
    required this.longBreakDuration,
    required this.shortBreakDuration,
    required this.pomodoroId,
    required this.pomodoroUniqueId,
    required this.pomodoroTimerProvider,
  });

  @override
  State<PomodoroTile> createState() => _PomodoroTileState();
}

class _PomodoroTileState extends State<PomodoroTile> {
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
                // Delete from firebase
                final user = FirebaseAuth.instance.currentUser;
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .collection('pomodoros')
                    .doc(widget.pomodoroId)
                    .delete();
                // Cancel the scheduled notification
                await NotificationService.cancelNotification(
                    widget.pomodoroUniqueId);
                // Show deleted confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Wrap(
                      children: [
                        const Text('Deleted: '),
                        Text(
                          widget.pomodoroName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                  Icons.delete_rounded,
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
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PomodoroTimerScreen(
              state: widget.pomodoroName,
              pomodoroId: widget.pomodoroId,
              pomodoroTimerProvider: widget.pomodoroTimerProvider,
              pomodoroUniqueId: widget.pomodoroUniqueId,
            ),
          ),
        ),
        child: Padding(
          padding: widget.innerPadding ?? const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 6.0),
                child: Icon(
                  Icons.timer,
                ),
              ),
              const SizedBox(
                width: 14,
              ),
              Expanded(
                child: Text(
                  widget.pomodoroName,
                  maxLines: 1,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat.MEd().format(widget.pomodoroDateTime),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    DateFormat('h:mm a').format(widget.pomodoroDateTime),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    ).animate().fade(delay: const Duration(milliseconds: 50));
  }
}
