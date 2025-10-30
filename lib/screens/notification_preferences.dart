import 'package:bloom/components/bloom_buttons.dart';
import 'package:bloom/responsive/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationPreferences extends StatefulWidget {
  const NotificationPreferences({super.key});

  @override
  State<NotificationPreferences> createState() =>
      _NotificationPreferencesState();
}

class _NotificationPreferencesState extends State<NotificationPreferences> {
  // Required variables
  bool? notificationEnabled;

  // Init state
  @override
  void initState() {
    super.initState();
    notificationEnabledCheck();
  }

  // Check if the notification permission is granted or not
  void notificationEnabledCheck() async {
    final granted = await Permission.notification.isGranted;
    if (granted == true) {
      setState(() {
        notificationEnabled = true;
      });
    } else {
      setState(() {
        notificationEnabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Padding(
        padding: MediaQuery.of(context).size.width < mobileWidth
            ? const EdgeInsets.all(0)
            : const EdgeInsets.symmetric(horizontal: 120),
        child: Column(
          children: [
            const SizedBox(
              height: 15,
            ),
            // Local reminder notifications
            BloomMaterialListTile(
              icon: notificationEnabled == true
                  ? Icon(Icons.notifications_active_rounded)
                  : Icon(Icons.notifications_off_rounded),
              label: 'All notifications',
              iconLabelSpace: 8,
              useSpacer: true,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              innerPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              endIcon: Text(
                notificationEnabled == true ? 'Enabled' : 'Disabled',
                style: TextStyle(
                    color: notificationEnabled == true
                        ? Theme.of(context).colorScheme.primary
                        : Colors.red),
              ),
              onTap: () async {},
            ),
            // Email notifications including promotional
            // const Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 14),
            //   child: BloomMaterialListTile(
            //     icon: SizedBox(),
            //     label: 'Email notifications',
            //     iconLabelSpace: 8,
            //     labelStyle:
            //         TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            //     innerPadding: EdgeInsets.symmetric(vertical: 12),
            //     endIcon: Text('No'),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
