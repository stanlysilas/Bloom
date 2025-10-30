import 'dart:io';
import 'dart:typed_data';

import 'package:bloom/components/bloom_buttons.dart';
import 'package:bloom/responsive/dimensions.dart';
import 'package:bloom/screens/about_app_screen.dart';
import 'package:bloom/screens/theme_and_colors_screen.dart';
import 'package:feedback/feedback.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
  bool isHTML = false;
  final user = FirebaseAuth.instance.currentUser;
  final Uri privacyPolicyUri =
      Uri.parse('https://bloomproductive.framer.website/privacy-policy');
  final Uri reportAnIssueUri =
      Uri.parse('https://bloomproductive.framer.website/#contact');

  @override
  void initState() {
    super.initState();
    // initBannerAd();
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text('Feedback sent succesfully. Thank you!'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          margin: const EdgeInsets.all(6),
          behavior: SnackBarBehavior.floating,
          showCloseIcon: true,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(platformResponse),
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

// Banner ADs initialization method
  void initBannerAd() {
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              content: Text('Failed to load the Ad. ${error.message}')));
        },
      ),
      request: const AdRequest(),
    );

    bannerAd.load();
  }

  Future<void> launchPrivacyPolicyUrl() async {
    if (!await launchUrl(privacyPolicyUri,
        mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $privacyPolicyUri');
    }
  }

  Future<void> launchReportAnIssueUrl() async {
    if (!await launchUrl(reportAnIssueUri,
        mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $reportAnIssueUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: MediaQuery.of(context).size.width < mobileWidth
            ? const EdgeInsets.all(0)
            : const EdgeInsets.symmetric(horizontal: 160),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preferences Section
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6),
                child: Text(
                  'Preferences',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
              // Theme & Colors Button
              BloomMaterialListTile(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24)),
                icon: Icon(Icons.color_lens,
                    color: Theme.of(context).colorScheme.onSecondaryContainer),
                iconLabelSpace: 8,
                label: 'Theme & Colors',
                subLabel: 'Light/Dark theme, Color schemes',
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                innerPadding: const EdgeInsets.all(16),
                outerPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 14),
                onTap: () {
                  // Navigate to Theme & Colors page
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ThemeAndColorsScreen()));
                },
                endIcon: Icon(Icons.keyboard_arrow_right_rounded),
              ),
              const SizedBox(height: 16),
              // Info Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Info',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
              const SizedBox(height: 6),
              // About Bloom Button
              BloomMaterialListTile(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4)),
                icon: Icon(Icons.android,
                    color: Theme.of(context).colorScheme.onSecondaryContainer),
                iconLabelSpace: 8,
                label: 'About Bloom',
                subLabel: 'App version, updates, changelog',
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                innerPadding: const EdgeInsets.all(16),
                outerPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 14),
                onTap: () {
                  // Navigate to About App page
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AboutAppScreen()));
                },
                endIcon: Icon(Icons.keyboard_arrow_right_rounded),
              ),
              // Bloom Privacy Policy Button
              BloomMaterialListTile(
                icon: Icon(Icons.privacy_tip,
                    color: Theme.of(context).colorScheme.onSecondaryContainer),
                iconLabelSpace: 8,
                label: 'Privacy Policy',
                subLabel: 'Read how we protect you',
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                innerPadding: const EdgeInsets.all(16),
                outerPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 14),
                onTap: () async {
                  await launchPrivacyPolicyUrl();
                },
                endIcon: Icon(Icons.open_in_browser),
              ),
              // Request a Feature Button
              BloomMaterialListTile(
                icon: Icon(Icons.new_releases,
                    color: Theme.of(context).colorScheme.onSecondaryContainer),
                iconLabelSpace: 8,
                label: 'Feature Request',
                subLabel: 'Suggest ideas for Bloom',
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                innerPadding: const EdgeInsets.all(16),
                outerPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 14),
                onTap: () async {
                  await launchReportAnIssueUrl();
                },
                endIcon: Icon(Icons.open_in_browser),
              ),
              // Feedback Button
              BloomMaterialListTile(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24)),
                icon: Icon(Icons.feedback,
                    color: Theme.of(context).colorScheme.onSecondaryContainer),
                iconLabelSpace: 8,
                label: 'Feedback',
                subLabel: 'Share your thoughts with us',
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                innerPadding: const EdgeInsets.all(16),
                outerPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 14),
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
                endIcon: Icon(Icons.keyboard_arrow_right_rounded),
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
    );
  }
}
