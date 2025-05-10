import 'dart:convert';

import 'package:bloom/components/mybuttons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
  final Uri downloadLatestVersionUri = Uri.parse(
      'https://drive.google.com/drive/folders/1-1yrxBKQtcWMIEDnDUZDLJVOPFsAtx6n?usp=drive_link');

  final String currentVersion = "2.2.1";
  late BannerAd bannerAd;
  bool isAdLoaded = false;
  bool? isUpdateAvailable;

  @override
  void initState() {
    super.initState();
    updateTagCheck();
    // initBannerAd();
  }

// Method to check and display a update available tag
  void updateTagCheck() {
    FirebaseFirestore.instance
        .collection('appData')
        .doc('appData')
        .get()
        .then((value) {
      if (value.exists && value['latestAndroidVersion'] != currentVersion) {
        setState(() {
          isUpdateAvailable = true;
        });
      } else {
        setState(() {
          isUpdateAvailable = false;
        });
      }
    });
  }

// Banner ADs initialization method
  initBannerAd() {
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: "ca-app-pub-5607290715305671/4045682095",
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Failed to load the add. ${error.message}')));
        },
      ),
      request: const AdRequest(),
    );

    bannerAd.load();
  }

  // Check for updates method
  void checkForUpdates() async {
    try {
      // Get the current app version
      // Update this when releasing a new version and also update the firebase field
      // Retrieve the latest version from Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('appData')
          .doc('appData')
          .get();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          margin: const EdgeInsets.all(6),
          behavior: SnackBarBehavior.floating,
          showCloseIcon: true,
          backgroundColor: Theme.of(context).primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Text('Checking for updates...'),
        ),
      );

      if (snapshot.exists) {
        final latestVersion = snapshot.data()?['latestAndroidVersion'] ?? '';

        if (latestVersion.isNotEmpty) {
          // Compare the versions
          if (latestVersion != currentVersion) {
            // Redirect to your website
            if (await canLaunchUrl(downloadLatestVersionUri)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  margin: const EdgeInsets.all(6),
                  behavior: SnackBarBehavior.floating,
                  showCloseIcon: true,
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  content: const Text(
                      'Update available, redirecting to the download page.'),
                ),
              );
              await launchUrl(downloadLatestVersionUri,
                  mode: LaunchMode.inAppWebView);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  margin: const EdgeInsets.all(6),
                  behavior: SnackBarBehavior.floating,
                  showCloseIcon: true,
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  content: Text('Could not launch $downloadLatestVersionUri'),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                margin: const EdgeInsets.all(6),
                behavior: SnackBarBehavior.floating,
                showCloseIcon: true,
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                content: const Text('App is up to date!'),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              margin: const EdgeInsets.all(6),
              behavior: SnackBarBehavior.floating,
              showCloseIcon: true,
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              content: const Text('Latest version not found in Firestore.'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            margin: const EdgeInsets.all(6),
            behavior: SnackBarBehavior.floating,
            showCloseIcon: true,
            backgroundColor: Theme.of(context).primaryColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: const Text('Document does not exist.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          margin: const EdgeInsets.all(6),
          behavior: SnackBarBehavior.floating,
          showCloseIcon: true,
          backgroundColor: Theme.of(context).primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text('Error checking for new version: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Load the ChangeLog JSON for Android
    Future<Map<String, dynamic>> loadChangelog() async {
      final data = await DefaultAssetBundle.of(context)
          .loadString('lib/required_data/changelog.json');
      return json.decode(data);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About app',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.0),
                child: Text(
                  'App name',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.0),
                child: Text(
                  '• Bloom - Productive',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.0),
                child: Text(
                  'App version',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Text(
                  '• Version: $currentVersion',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.0),
                child: Text(
                  'Update channel',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.0),
                child: Text(
                  '• Stable',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              FutureBuilder<Map<String, dynamic>>(
                future: loadChangelog(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: Text("Error loading changelog."));
                  }

                  final changelog = snapshot.data!;
                  final versionData = changelog[currentVersion];

                  if (versionData == null) {
                    return const Center(child: Text("No changelog available."));
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          versionData["title"],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        ...List.generate(
                          versionData["features"].length,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "• ",
                                  style: TextStyle(fontSize: 16),
                                ),
                                Expanded(
                                  child: Text(
                                    versionData["features"][index],
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 12,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.0),
                child: Text(
                  'Check for updates',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              // Check for updates button
              ExtraOptionsButton(
                icon: const Icon(Icons.system_update_alt_rounded),
                iconLabelSpace: 8,
                label: isUpdateAvailable == true
                    ? 'Download update'
                    : 'Check for updates',
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                showTag: isUpdateAvailable,
                tagIcon: const Icon(
                  Icons.emergency_outlined,
                  size: 14,
                ),
                tagLabel: 'Update available',
                innerPadding: const EdgeInsets.all(12),
                endIcon: const Icon(Icons.open_in_new_rounded),
                onTap: checkForUpdates,
              ),
              const SizedBox(
                height: 12,
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
