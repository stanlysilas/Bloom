import 'package:flutter/material.dart';

class SyncIndicator extends StatelessWidget {
  final bool isSyncing;
  const SyncIndicator({super.key, required this.isSyncing});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 2),
        child: Tooltip(
          triggerMode: TooltipTriggerMode.tap,
          message: isSyncing ? 'Syncing' : 'Synced',
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.surfaceContainer,
            ),
            child: Container(
              height: 8,
              width: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: isSyncing ? Colors.blue : Colors.green,
              ),
            ),
          ),
        ));
  }
}
