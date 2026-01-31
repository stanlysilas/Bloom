import 'package:bloom/authentication_screens/bloom_pin_service.dart';
import 'package:bloom/authentication_screens/password_entry_screen.dart';
import 'package:bloom/components/bloom_buttons.dart';
import 'package:flutter/material.dart';

class ManagePrivacyPinScreen extends StatefulWidget {
  const ManagePrivacyPinScreen({super.key});

  @override
  State<ManagePrivacyPinScreen> createState() => _ManagePrivacyPinScreenState();
}

class _ManagePrivacyPinScreenState extends State<ManagePrivacyPinScreen> {
  bool? isPinEnabled;
  @override
  void initState() {
    super.initState();
    isPinSet();
  }

  /// Check if the Privacy PIN is enabled or not
  void isPinSet() async {
    final isPinSet = await BloomPinService().isPinEnabled();
    if (isPinSet == true) {
      setState(() {
        isPinEnabled = true;
      });
    } else {
      setState(() {
        isPinEnabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.surfaceContainer)),
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back, color: Colors.grey)),
        title: Text('Manage Privacy PIN',
            style: TextStyle(
                fontFamily: 'ClashGrotesk', fontWeight: FontWeight.w500)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
        child: Column(
          children: [
            // Update/Set PIN button
            BloomMaterialListTile(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4)),
              icon: Icon(isPinEnabled == true ? Icons.lock : Icons.lock_open,
                  color: Theme.of(context).colorScheme.onSecondaryContainer),
              color: Theme.of(context).colorScheme.surfaceContainer,
              label: 'Update PIN',
              subLabel: 'Change your Privacy PIN',
              iconLabelSpace: 8,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
              innerPadding: const EdgeInsets.all(16),
              outerPadding: EdgeInsets.symmetric(vertical: 1),
              onTap: () async {
                // TODO: SHOULD CHANGE OR UPDATE THE EXISTING BLOOM PIN
                final authenticated = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) => const PasswordEntryScreen(
                      mode: PinMode.set,
                      message:
                          'Set a new Privacy PIN. Your existing PIN will be removed and modified.',
                    ),
                  ),
                );
                if (authenticated == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      margin: const EdgeInsets.all(6),
                      behavior: SnackBarBehavior.floating,
                      showCloseIcon: true,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      content:
                          Text('Privacy PIN updated and modified succesfully'),
                    ),
                  );
                }
              },
              endIcon: const Icon(Icons.keyboard_arrow_right_rounded),
            ),
            // Remove PIN button
            isPinEnabled == true
                ? BloomMaterialListTile(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24)),
                    icon: Icon(Icons.delete,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer),
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    label: 'Remove PIN',
                    subLabel: 'Remove your Privacy PIN',
                    iconLabelSpace: 8,
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 18),
                    innerPadding: const EdgeInsets.all(16),
                    outerPadding: EdgeInsets.symmetric(vertical: 1),
                    onTap: () async {
                      showAdaptiveDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog.adaptive(
                              icon: Icon(Icons.error),
                              iconColor: Theme.of(context).colorScheme.error,
                              title: Text('Delete Privacy PIN?'),
                              content: Text(
                                'Do you really want to remove your Privacy PIN? This means your Privacy PIN will be removed completely. All your locked objects will still be locked.',
                              ),
                              actions: [
                                // Cancel Button
                                FilledButton(
                                    onPressed: () {
                                      // Cancel button and close the Dialog
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('No, keep PIN')),
                                // Cancel Button
                                TextButton(
                                    style: ButtonStyle(
                                        foregroundColor: WidgetStatePropertyAll(
                                            Theme.of(context)
                                                .colorScheme
                                                .error)),
                                    onPressed: () async {
                                      // Remove PIN and close the Dialog
                                      await BloomPinService().clearPin();
                                      Navigator.of(context).pop();
                                      // Update the UI
                                      setState(() {});
                                    },
                                    child: Text('Yes, remove PIN')),
                              ],
                            );
                          });
                    },
                    endIcon: const Icon(Icons.keyboard_arrow_right_rounded),
                  )
                : SizedBox(),
            // Created At date and time
          ],
        ),
      ),
    );
  }
}
