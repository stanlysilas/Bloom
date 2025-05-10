import 'dart:io';
import 'dart:typed_data';

import 'package:bloom/components/mybuttons.dart';
import 'package:bloom/responsive/dimensions.dart';
import 'package:bloom/screens/about_app_screen.dart';
import 'package:bloom/screens/notification_preferences.dart';
// import 'package:bloom/screens/test_screen.dart';
import 'package:bloom/subscriptions/subscriptions_banner.dart';
import 'package:bloom/theme/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feedback/feedback.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  final String? font;
  const SettingsPage({super.key, this.font});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // late String font;
  late BannerAd bannerAd;
  bool isAdLoaded = false;
  int? colorSchemeValue = 0;
  int? themeSchemeValue;
  bool isHTML = false;
  String? subscriptionPlan;
  final user = FirebaseAuth.instance.currentUser;
  final Uri privacyPolicyUri = Uri.parse(
      'https://www.freeprivacypolicy.com/live/8139588e-c4a8-4458-9783-4ca5ce80140d');
  final Uri reportAnIssueUri =
      Uri.parse('https://bloomproductive.wixsite.com/bloomproductive');

  @override
  void initState() {
    super.initState();
    // initBannerAd();
    getThemeSchemeValue();
    subscriptionPlanCheck();
  }

// Method to check and display a update available tag
  void subscriptionPlanCheck() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get()
        .then((value) {
      if (value.exists && value.data()!.containsKey('subscriptionPlan')) {
        setState(() {
          if (value['subscriptionPlan'] == 'free' ||
              value['subscriptionPlan'] == '' ||
              value['subscriptionPlan'] == null) {
            subscriptionPlan = 'free';
          } else if (value['subscriptionPlan'] == 'pro') {
            subscriptionPlan = 'pro';
          } else {
            subscriptionPlan = 'ultra';
          }
        });
      } else {
        setState(() {
          subscriptionPlan = 'free';
        });
      }
    });
  }

  // Method to send the email to the developer
  Future<void> send(String body, List<String> attachments) async {
    final Email email = Email(
      body: body,
      subject: 'Feedback from a User',
      recipients: ['bloomproductivehelp@gmail.com', 'vstanlysilas@gmail.com'],
      attachmentPaths: attachments,
      isHTML: isHTML,
    );

    String platformResponse;

    try {
      await FlutterEmailSender.send(email);
      platformResponse = 'success';
    } catch (error) {
      platformResponse = error.toString();
    }

    if (!mounted) return;

    if (platformResponse == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          margin: const EdgeInsets.all(6),
          behavior: SnackBarBehavior.floating,
          showCloseIcon: true,
          backgroundColor: Theme.of(context).primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(
            'Feedback sent succesfully. Thank you!',
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          margin: const EdgeInsets.all(6),
          behavior: SnackBarBehavior.floating,
          showCloseIcon: true,
          backgroundColor: Theme.of(context).primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(
            platformResponse,
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
        ),
      );
    }
  }

  // Write image to storage function for storing the screenshot temporarirly
  Future<String> writeImageToStorage(Uint8List feedbackScreenShot) async {
    final Directory output = Directory.systemTemp;
    final String screenshotFilePath = '${output.path}/feedback.png';
    final File screenshotFile = File(screenshotFilePath);
    await screenshotFile.writeAsBytes(feedbackScreenShot);
    return screenshotFilePath;
  }

  // Get the themeSchemeValue from SharedPreferences
  void getThemeSchemeValue() async {
    final prefs = await SharedPreferences.getInstance();
    final String themePreference =
        prefs.getString('themeSchemeValue') ?? 'system';

    if (themePreference == 'light') {
      setState(() {
        themeSchemeValue = 0;
      });
    } else if (themePreference == 'dark') {
      setState(() {
        themeSchemeValue = 1;
      });
    } else {
      setState(() {
        themeSchemeValue = 2;
      });
    }
  }

// Banner ADs initialization method
  initBannerAd() {
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: "ca-app-pub-5607290715305671/5550335450",
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              margin: const EdgeInsets.all(6),
              behavior: SnackBarBehavior.floating,
              showCloseIcon: true,
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              content: Text(
                'Failed to load the Ad. ${error.message}',
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color),
              )));
        },
      ),
      request: const AdRequest(),
    );

    bannerAd.load();
  }

  Future<void> launchPrivacyPolicyUrl() async {
    if (!await launchUrl(privacyPolicyUri, mode: LaunchMode.inAppWebView)) {
      throw Exception('Could not launch $privacyPolicyUri');
    }
  }

  Future<void> launchReportAnIssueUrl() async {
    if (!await launchUrl(reportAnIssueUri, mode: LaunchMode.inAppWebView)) {
      throw Exception('Could not launch $reportAnIssueUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Settings',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        body: Padding(
          padding: MediaQuery.of(context).size.width < mobileWidth
              ? const EdgeInsets.symmetric(horizontal: 14)
              : const EdgeInsets.symmetric(horizontal: 250),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                // Warning to restart the app after changing some settings
                // font != widget.font
                //     ? const Padding(
                //         padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 14),
                //         child: Text(
                //           'To see the changes of some settings, you need to restart the app.',
                //           style: TextStyle(color: Colors.red),
                //         ),
                //       )
                //     : const SizedBox(),
                // Upgrade the subscription plan banner
                SubscriptionsBanner(
                  isFreeUser: subscriptionPlan == 'free' ? true : false,
                  currentDate: DateTime.now(),
                ),
                const SizedBox(
                  height: 15,
                ),
                // Settings for changing app appearance
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preferences',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color),
                      ),
                      const Text(
                        'Options to change the app preferences',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      // App theme switching option
                      const Text(
                        'Theme',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      const Text(
                        'Change the main theme of the app',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      SizedBox(
                        width: double.maxFinite,
                        child: SegmentedButton<int>(
                          selected: <int>{themeSchemeValue ?? 2},
                          showSelectedIcon: false,
                          segments: [
                            ButtonSegment(
                                value: 0,
                                icon: Icon(Icons.sunny,
                                    color: themeSchemeValue != 0
                                        ? Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color
                                        : Colors.black),
                                label: Text(
                                  'Light',
                                  style: TextStyle(
                                      color: themeSchemeValue != 0
                                          ? Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color
                                          : Colors.black),
                                )),
                            ButtonSegment(
                                value: 1,
                                icon: Icon(Icons.mode_night_rounded,
                                    color: themeSchemeValue != 1
                                        ? Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color
                                        : Colors.black),
                                label: Text(
                                  'Dark',
                                  style: TextStyle(
                                      color: themeSchemeValue != 1
                                          ? Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color
                                          : Colors.black),
                                )),
                            ButtonSegment(
                                value: 2,
                                icon: Icon(Icons.phone_android_rounded,
                                    color: themeSchemeValue != 2
                                        ? Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color
                                        : Colors.black),
                                label: Text(
                                  'System',
                                  style: TextStyle(
                                      color: themeSchemeValue != 2
                                          ? Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color
                                          : Colors.black),
                                )),
                          ],
                          onSelectionChanged: (value) {
                            setState(() {
                              themeSchemeValue = value.first;
                            });

                            final themeProvider = Provider.of<ThemeProvider>(
                                context,
                                listen: false);

                            if (themeSchemeValue == 0) {
                              themeProvider.theme = 'light';
                            } else if (themeSchemeValue == 1) {
                              themeProvider.theme = 'dark';
                            } else {
                              themeProvider.theme = 'system';
                            }
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      // Notifications settings
                      ExtraOptionsButton(
                        icon: const Icon(Icons.notifications_none_rounded),
                        iconLabelSpace: 8,
                        label: 'Notifications',
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                        endIcon: const Icon(Iconsax.arrow_right),
                        innerPadding: const EdgeInsets.symmetric(vertical: 12),
                        onTap: () {
                          // Navigate to the notification preferences or settings screen
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  const NotificationPreferences()));
                        },
                      ),
                      // const Divider(),
                      // // Change color scheme of the app title & button
                      // const Text(
                      //   'Color scheme',
                      //   style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      // ),
                      // const SizedBox(
                      //   height: 12,
                      // ),
                      // SizedBox(
                      //   width: double.maxFinite,
                      //   child: CupertinoSlidingSegmentedControl(
                      //     thumbColor: Theme.of(context).primaryColor,
                      //     children: {
                      //       0: Container(
                      //         height: 12,
                      //         width: 12,
                      //         decoration: BoxDecoration(
                      //           borderRadius: BorderRadius.circular(100),
                      //           color: Theme.of(context).primaryColor,
                      //         ),
                      //       ),
                      //       1: Container(
                      //         height: 12,
                      //         width: 12,
                      //         decoration: BoxDecoration(
                      //           borderRadius: BorderRadius.circular(100),
                      //           color: primaryColorLightMode,
                      //         ),
                      //       ),
                      //       2: Container(
                      //         height: 12,
                      //         width: 12,
                      //         decoration: BoxDecoration(
                      //             borderRadius: BorderRadius.circular(100),
                      //             color: secondaryColorLightMode),
                      //       ),
                      //     },
                      //     onValueChanged: (value) {
                      //       setState(() {
                      //         colorSchemeValue = value;
                      //         print(colorSchemeValue);
                      //       });
                      //     },
                      //     groupValue: colorSchemeValue,
                      //   ),
                      // ),
                      const SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                // Settings for showing help, report buttons
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Info',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color),
                      ),
                      const Text(
                        'Check for updates, privacy policy, report an issue and more',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ExtraOptionsButton(
                        label: 'About app',
                        iconLabelSpace: 8,
                        icon: const Icon(Icons.android_rounded),
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                        innerPadding: const EdgeInsets.symmetric(vertical: 12),
                        endIcon: const Icon(Iconsax.arrow_right),
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => const AboutAppScreen())),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ExtraOptionsButton(
                        label: 'Privacy Policy',
                        iconLabelSpace: 8,
                        icon: const Icon(Icons.privacy_tip_outlined),
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                        innerPadding: const EdgeInsets.symmetric(vertical: 12),
                        endIcon: const Icon(Icons.open_in_new_rounded),
                        onTap: () async {
                          await launchPrivacyPolicyUrl();
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ExtraOptionsButton(
                        label: 'Request a feature',
                        iconLabelSpace: 8,
                        icon: const Icon(Icons.report_gmailerrorred_rounded),
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                        innerPadding: const EdgeInsets.symmetric(vertical: 12),
                        endIcon: const Icon(Icons.open_in_new_rounded),
                        onTap: () async {
                          await launchReportAnIssueUrl();
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      // Option to ask the users to give feedback on the app
                      ExtraOptionsButton(
                        icon: const Icon(Icons.feedback_outlined),
                        iconLabelSpace: 8,
                        label: 'Feedback',
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        innerPadding: const EdgeInsets.symmetric(vertical: 12),
                        endIcon: const Icon(Iconsax.arrow_right),
                        onTap: () {
                          // Show a modal sheet to collect the feedback and rating of the user for the app
                          BetterFeedback.of(context)
                              .show((UserFeedback feedback) async {
                            // Get the path to the screenshot
                            final screenshotFilePath =
                                await writeImageToStorage(feedback.screenshot);
                            send(feedback.text, [screenshotFilePath]);
                          });
                        },
                      ),
                      // Display the testing screen here. WARNING: Delete or comment the code for release builds. Do not leave this code intact for release builds!!!
                      // ExtraOptionsButton(
                      //   icon: const Icon(Icons.feedback_outlined),
                      //   iconLabelSpace: 8,
                      //   label: 'Testing screen',
                      //   labelStyle: const TextStyle(
                      //     fontWeight: FontWeight.w600,
                      //     fontSize: 16,
                      //   ),
                      //   innerPadding: const EdgeInsets.symmetric(vertical: 12),
                      //   endIcon: const Icon(Iconsax.arrow_right),
                      //   onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      //       builder: (context) => const TestScreen())),
                      // ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar:
            // Display and AD in between the events tile and tasks tile (testing)
            isAdLoaded
                ? SizedBox(
                    height: bannerAd.size.height.toDouble(),
                    width: bannerAd.size.width.toDouble(),
                    child: Center(child: AdWidget(ad: bannerAd)),
                  )
                : const SizedBox(),
      ),
    );
  }
}
