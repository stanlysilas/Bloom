import 'package:flutter/material.dart';

class RecurringTaskSection extends StatelessWidget {
  final bool isRecurring;
  final List<int> selectedDays;
  final Function(bool) onToggle;
  final Function(int) onDayToggle;

  const RecurringTaskSection({
    super.key,
    required this.isRecurring,
    required this.selectedDays,
    required this.onToggle,
    required this.onDayToggle,
  });

  @override
  Widget build(BuildContext context) {
    const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

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
              const Text('Recurring'),
              const Spacer(),
              Switch(
                value: isRecurring,
                onChanged: onToggle,
              ),
            ],
          ),
          if (isRecurring) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(days.length, (index) {
                final selected = selectedDays.contains(index);

                return InkWell(
                  onTap: () => onDayToggle(index),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.secondaryContainer,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      days[index],
                      style: TextStyle(
                        color: selected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}
