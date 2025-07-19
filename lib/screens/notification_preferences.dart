import 'package:bloom/components/mybuttons.dart';
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
            ExtraOptionsButton(
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
                        ? Theme.of(context).primaryColor
                        : Colors.red),
              ),
              onTap: () async {
                if (notificationEnabled == false) {
                  await Permission.notification.request();
                } else {
                  // Confirmation dialog to turn off notifications for reminders
                  showAdaptiveDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog.adaptive(
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          icon: Icon(notificationEnabled == true
                              ? Icons.warning_amber_rounded
                              : Icons.notifications_active_outlined),
                          iconColor: notificationEnabled == true
                              ? Colors.red
                              : Theme.of(context).primaryColor,
                          title: Text(
                            notificationEnabled == true
                                ? 'Disable notifications?'
                                : "Enable notifications?",
                          ),
                          titleTextStyle: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                          ),
                          content: Text(
                            "Do you want to ${notificationEnabled == true ? 'disable' : 'enable'} all notifications? ${notificationEnabled == true ? "You won't be able to receive any reminders, updates and more" : ''}",
                          ),
                          contentTextStyle: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400),
                          actions: [
                            TextButton(
                              onPressed: () {
                                // Cancel and close the dialog
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Cancel',
                              ),
                            ),
                            TextButton(
                              style: ButtonStyle(
                                  foregroundColor: WidgetStatePropertyAll(
                                      notificationEnabled == false
                                          ? Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color
                                          : Colors.red)),
                              onPressed: () async {
                                // Go to settings
                                await openAppSettings();
                                Navigator.pop(context);
                              },
                              child: Text('Turn off'),
                            ),
                          ],
                        );
                      });
                }
              },
            ),
            // Email notifications including promotional
            // const Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 14),
            //   child: ExtraOptionsButton(
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
