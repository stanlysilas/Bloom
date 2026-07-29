import 'package:bloom/features/calendar/calendar_screen.dart';
import 'package:bloom/features/home/widgets/calendar_header_delegate.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarHeader extends StatefulWidget {
  final DateTime selectedDay;
  final Function(DateTime) onDayChanged;
  const CalendarHeader(
      {super.key, required this.selectedDay, required this.onDayChanged});

  @override
  State<CalendarHeader> createState() => _CalendarHeaderState();
}

class _CalendarHeaderState extends State<CalendarHeader> {
  DateTime _focusedDay = DateTime.now();
  CalendarFormat calendarFormat = CalendarFormat.week;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      floating: false,
      delegate: CalendarHeaderDelegate(
        minExtent: 90,
        maxExtent: 100,
        childBuilder: (context, shrinkOffset) {
          final scrollPercent = (shrinkOffset / (100 - 90)).clamp(0.0, 1.0);
          final color = Color.lerp(
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surfaceContainerHigh,
            scrollPercent,
          )!;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            color: color,
            padding: const EdgeInsets.only(left: 14.0, right: 14.0, top: 14),
            child: TableCalendar(
              focusedDay: _focusedDay,
              headerVisible: false,
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontWeight: FontWeight.w500),
              ),
              availableCalendarFormats: const {
                CalendarFormat.week: 'Week',
              },
              selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),
              calendarFormat: calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  calendarFormat = format;
                });
              },
              onDaySelected: (selectedDay, focusedDay) {
                widget.onDayChanged(selectedDay);
                _focusedDay = focusedDay;
              },
              onDayLongPressed: (selectedDay, focusedDay) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      CalendarViewScreen(initialDay: selectedDay),
                ));
              },
              calendarStyle: CalendarStyle(
                isTodayHighlighted: false,
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
