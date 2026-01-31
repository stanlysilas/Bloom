import 'package:flutter/material.dart';

class DeleteConfirmationDialog extends StatefulWidget {
  /// Displays a confirmation dialog as a warning before deleting any object.
  /// [objectName] is [String] that will be displayed in the [AlertDialog].
  /// [onPressed] takes a [VoidCallback] and performs the action specified when deletion is confirmed.
  final String objectName;
  final VoidCallback onPressed;
  const DeleteConfirmationDialog(
      {super.key, required this.onPressed, required this.objectName});

  @override
  State<DeleteConfirmationDialog> createState() =>
      _DeleteConfirmationDialogState();
}

class _DeleteConfirmationDialogState extends State<DeleteConfirmationDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(Icons.warning),
      iconColor: Theme.of(context).colorScheme.error,
      title: Text(
        'Confirm deletion?',
        style: TextStyle(
          fontFamily: 'ClashGrotesk',
        ),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("'${widget.objectName}', will be permanently deleted.",
              maxLines: 2),
          Text("Are you sure you want to delete it?"),
        ],
      ),
      actions: [
        FilledButton(
            onPressed: () {
              // Cancel the deletion and close dialog
              Navigator.of(context).pop();
            },
            child: Text('Cancel')),
        TextButton(
            onPressed: widget.onPressed,
            style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.error)),
            child: Text('Confirm'))
      ],
    );
  }
}
