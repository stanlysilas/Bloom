import 'package:bloom/components/mybuttons.dart';
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
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          // Local reminder notifications
          ExtraOptionsButton(
            icon: const Icon(Icons.phone_android_rounded),
            label: 'Reminder notifications',
            iconLabelSpace: 8,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            innerPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            endIcon: Text(notificationEnabled == true ? 'Enabled' : 'Disabled'),
            onTap: () async {
              if (notificationEnabled == false) {
                await Permission.notification.request();
              } else {
                // Confirmation dialog to turn off notifications for reminders
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog.adaptive(
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        icon: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(notificationEnabled == true
                              ? Icons.warning_amber_rounded
                              : Icons.notifications_active_outlined),
                        ),
                        iconColor: notificationEnabled == true
                            ? Colors.red
                            : Theme.of(context).primaryColor,
                        title: Text(
                          notificationEnabled == true
                              ? 'Disable notifications?'
                              : "Enable notifications?",
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                        titleTextStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4.0, vertical: 14),
                        content: Text(
                          "Do you want to ${notificationEnabled == true ? 'disable' : 'enable'} reminder notifications? ${notificationEnabled == true ? "You won't be able to receive any task or event reminders" : ''}",
                          textAlign: TextAlign.center,
                        ),
                        actions: [
                          InkWell(
                            borderRadius: BorderRadius.circular(100),
                            onTap: () {
                              // Cancel and close the dialog
                              Navigator.pop(context);
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Text(
                                'Cancel',
                              ),
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(100),
                            onTap: () async {
                              // Go to settings
                              await openAppSettings();
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                'Turn off',
                                style: TextStyle(
                                    color: notificationEnabled == false
                                        ? Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color
                                        : Colors.red),
                              ),
                            ),
                          ),
                        ],
                        actionsPadding: const EdgeInsets.all(10),
                        actionsAlignment: MainAxisAlignment.end,
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
    );
  }
}
