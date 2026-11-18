import 'package:bloom/services/firebase/notification.dart';
import 'package:bloom/services/permissions/storage_permission.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class OnboardingPermissions extends StatelessWidget {
  final Future<void> Function() onGranted;

  const OnboardingPermissions({
    super.key,
    required this.onGranted,
  });

  Future<void> _requestPermissions(BuildContext context) async {
    if (kIsWeb) {
      await _showWebNotificationDialog(context);
      await onGranted();
      return;
    }

    final granted =
        await NotificationService.init() && await StoragePermission.init();

    if (!context.mounted) return;

    if (granted) {
      await onGranted();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Permission access denied. Bloom might not run as expected.',
        ),
      ),
    );
  }

  Future<void> _showWebNotificationDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          constraints: const BoxConstraints(maxWidth: 450),
          icon: Icon(
            Icons.warning_amber_rounded,
            color: Theme.of(context).colorScheme.error,
          ),
          title: const Text('Notifications unavailable'),
          content: const Text(
            'Notifications on web platforms are currently unavailable. '
            'We will support them in a future update.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Never miss a task, event or deadline',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 24),
          _PermissionItem(
            icon: Icons.task_alt_rounded,
            label: 'Remind you of your tasks',
          ),
          const _PermissionDivider(),
          _PermissionItem(
            icon: Icons.calendar_month_rounded,
            label: 'Remind you of your events',
          ),
          const _PermissionDivider(),
          _PermissionItem(
            icon: Icons.download_rounded,
            label: 'Download and update automatically',
          ),
          const _PermissionDivider(),
          const _PermissionItem(
            icon: Icons.more_horiz_rounded,
            label: 'And much more',
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _requestPermissions(context),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Get started'),
          ),
        ],
      ),
    );
  }
}

class _PermissionItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PermissionItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label),
          ),
        ],
      ),
    );
  }
}

class _PermissionDivider extends StatelessWidget {
  const _PermissionDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Divider(),
    );
  }
}
