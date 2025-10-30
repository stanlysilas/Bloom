import 'dart:convert';

import 'package:bloom/bloom_updater.dart';
import 'package:bloom/components/bloom_buttons.dart';
import 'package:bloom/responsive/dimensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
  String currentVersion = 'default';
  String newVersion = '';
  late int buildNumberAndroid = 0;
  late BannerAd bannerAd;
  bool isAdLoaded = false;
  bool? isUpdateAvailable;

  @override
  void initState() {
    super.initState();
    updateCheck();
    getAppInfo();
    // initBannerAd();
  }

  Future<void> getAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      currentVersion = info.version;
      buildNumberAndroid = int.tryParse(info.buildNumber) ?? 0;
    });
  }

// Method to check and display a update available tag
  void updateCheck() async {
    await FirebaseFirestore.instance
        .collection('appData')
        .doc('appData')
        .get()
        .then((value) {
      setState(() {
        if (value.exists && value['buildNumberAndroid'] > buildNumberAndroid) {
          isUpdateAvailable = true;
          newVersion = value['latestAndroidVersion'];
        } else {
          isUpdateAvailable = false;
          newVersion = currentVersion;
        }
      });
    });
  }

// Banner ADs initialization method
  void initBannerAd() {
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

      if (snapshot.exists) {
        final int latestBuildNumberAndroid =
            snapshot.data()?['buildNumberAndroid'];

        if (latestBuildNumberAndroid != 0) {
          // Compare the versions
          if (latestBuildNumberAndroid > buildNumberAndroid) {
            // Show the download and update dialog
            showAdaptiveDialog(
                context: context,
                builder: (context) {
                  return AlertDialog.adaptive(
                    icon: const Icon(Icons.download),
                    title: Text('New Update Available!'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                            "Click Update to Download the update and click on install/update when prompted."),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text(
                            "If prompted please allow storage permission and install unknowm APK, as this is necessary for Bloom to download and update itself"),
                        const SizedBox(
                          height: 16,
                        ),
                        const Text(
                            "Note: We neither collect any information nor download any other malicious APKs"),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          // Cancel and close the dialog
                          Navigator.pop(context);
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          // Download and Update the APK
                          await BloomUpdater.downloadAndInstallApk(context);
                          // Cancel and close the dialog
                          Navigator.pop(context);
                        },
                        child: Text('Update'),
                      ),
                    ],
                    actionsPadding: const EdgeInsets.all(10),
                    actionsAlignment: MainAxisAlignment.end,
                  );
                });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                margin: const EdgeInsets.all(6),
                behavior: SnackBarBehavior.floating,
                showCloseIcon: true,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                content: const Text('Bloom is up to date!'),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              margin: const EdgeInsets.all(6),
              behavior: SnackBarBehavior.floating,
              showCloseIcon: true,
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
        title: const Text('About Bloom'),
      ),
      body: SafeArea(
        child: Padding(
          padding: MediaQuery.of(context).size.width < mobileWidth
              ? const EdgeInsets.all(0)
              : const EdgeInsets.symmetric(horizontal: 120),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),
                // About App section
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 14),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(24)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon of Bloom
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            borderRadius: BorderRadius.circular(16)),
                        child: Image.asset(
                          'assets/icons/default_app_icon_png.png',
                          scale: 16,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Name, version and channel of Bloom
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name of Bloom
                          Text(
                            'Bloom - Productive',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          // Version+BuildNumber
                          Text("Version $currentVersion+$buildNumberAndroid"),
                          // Channel of the app update
                          Text('Beta Channel')
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // ChangeLog Block
                FutureBuilder<Map<String, dynamic>>(
                  future: loadChangelog(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: CircularProgressIndicator(year2023: false));
                    } else if (snapshot.hasError) {
                      return const Center(
                          child: Text("Error loading changelog."));
                    }

                    final changelog = snapshot.data!;
                    final versionData = changelog[currentVersion];

                    if (versionData == null) {
                      return Center(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            'No changelog data available for version: $currentVersion'),
                      ));
                    }

                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 14),
                      padding: const EdgeInsets.all(14.0),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(24)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            versionData["title"],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          ...List.generate(
                            versionData["features"].length,
                            (index) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (versionData['features'] != null)
                                    const Text(
                                      "• ",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  if (versionData['features'] != null)
                                    Expanded(
                                      child:
                                          Text(versionData["features"][index]),
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
                const SizedBox(height: 16),
                // Check for updates button for Android
                if (!kIsWeb)
                  BloomMaterialListTile(
                    borderRadius: BorderRadius.circular(24),
                    icon: const Icon(Icons.download),
                    label: isUpdateAvailable == true
                        ? 'Download Update'
                        : 'Check for Updates',
                    subLabel: isUpdateAvailable == true
                        ? "Version $newVersion is live now!"
                        : 'You are on the latest version',
                    showTag: isUpdateAvailable,
                    tagIcon: const Icon(
                      Icons.new_releases,
                      size: 14,
                    ),
                    tagLabel: 'Update available',
                    innerPadding: const EdgeInsets.all(12),
                    onTap: checkForUpdates,
                  ),
              ],
            ),
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
