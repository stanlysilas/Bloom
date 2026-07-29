import 'package:bloom/core/widgets/delete_confirmation_dialog.dart';
import 'package:bloom/features/goals/events/screens/event_details_screen.dart';
import 'package:bloom/models/event_model.dart';
import 'package:bloom/services/firebase/event_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class EventsTile extends StatelessWidget {
  final EventModel eventModel;
  final EdgeInsetsGeometry? innerPadding;
  final BoxDecoration? decoration;
  final BorderRadius? borderRadius;

  const EventsTile({
    super.key,
    required this.eventModel,
    this.innerPadding,
    this.decoration,
    this.borderRadius,
  });

  bool get isOverdue =>
      eventModel.endDateTime != null &&
      eventModel.endDateTime!.isBefore(DateTime.now()) &&
      !eventModel.isCompleted;

  @override
  Widget build(BuildContext context) {
    final date = isOverdue ? eventModel.endDateTime! : eventModel.dateTime;

    return Slidable(
      key: ValueKey(eventModel.objectId),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: () => EventService.markAttended(eventModel),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: eventModel.color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.event_available_rounded),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => DeleteConfirmationDialog(
                    objectName: eventModel.name,
                    onPressed: () {
                      EventService.deleteEvent(eventModel);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.delete_rounded,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      child: Material(
        borderRadius: borderRadius ?? BorderRadius.circular(0),
        child: InkWell(
          borderRadius: borderRadius ?? BorderRadius.circular(0),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EventDetailsScreen(
                  eventId: eventModel.objectId,
                  eventName: eventModel.name,
                  eventNotes: eventModel.description ?? '',
                  eventStartDateTime: eventModel.dateTime,
                  eventEndDateTime: eventModel.endDateTime,
                  eventColorCode: eventModel.color,
                  eventUniqueId: eventModel.uniqueNotificationId ?? 0,
                  isAttended: eventModel.isCompleted,
                ),
              ),
            );
          },
          child: Container(
            padding: innerPadding,
            decoration: decoration,
            child: Row(
              children: [
                _EventIcon(color: eventModel.color),
                const SizedBox(width: 6),
                Expanded(
                  child: _EventContent(
                    event: eventModel,
                    isOverdue: isOverdue,
                  ),
                ),
                _EventTime(
                  date: date,
                  isOverdue: isOverdue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EventIcon extends StatelessWidget {
  final Color color;

  const _EventIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.calendar_month_rounded),
    );
  }
}

class _EventContent extends StatelessWidget {
  final EventModel event;
  final bool isOverdue;

  const _EventContent({
    required this.event,
    required this.isOverdue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        if (isOverdue)
          const Text(
            'Overdue',
            style: TextStyle(color: Colors.red),
          ),
      ],
    );
  }
}

class _EventTime extends StatelessWidget {
  final DateTime date;
  final bool isOverdue;

  const _EventTime({
    required this.date,
    required this.isOverdue,
  });

  @override
  Widget build(BuildContext context) {
    final color = isOverdue ? Colors.red : Colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          DateFormat.MEd().format(date),
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isOverdue ? Colors.red : null,
          ),
        ),
        Text(
          DateFormat('h:mm a').format(date),
          style: TextStyle(color: color),
        ),
      ],
    );
  }
}
