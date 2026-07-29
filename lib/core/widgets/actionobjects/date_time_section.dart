import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeSection extends StatelessWidget {
  final DateTime date;
  final TimeOfDay time;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;

  const DateTimeSection({
    super.key,
    required this.date,
    required this.time,
    required this.onPickDate,
    required this.onPickTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('Date'),
              const Spacer(),
              InkWell(
                onTap: onPickDate,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    DateFormat('dd-MM-yyyy').format(date),
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
          Row(
            children: [
              const Text('Time'),
              const Spacer(),
              InkWell(
                onTap: onPickTime,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(time.format(context)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
