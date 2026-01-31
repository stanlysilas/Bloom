import 'dart:convert';

import 'package:bloom/bloom_updater.dart';
import 'package:bloom/components/bloom_buttons.dart';
import 'package:bloom/models/changelog_model.dart';
import 'package:bloom/responsive/dimensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String status = 'unknown';
  final Uri downloadAndroidApkUri = Uri.parse(
      'https://github.com/stanlysilas/Bloom/releases/latest/download/Bloom.apk');
  final Uri visitGitHubRepoUri =
      Uri.parse('https://github.com/stanlysilas/Bloom');

  @override
  void initState() {
    super.initState();
    updateCheck();
    getAppInfo();
    fetchChangelog();
    // initBannerAd();
  }

  Future<void> launchDownloadAndroidApkUrl() async {
    if (!await launchUrl(downloadAndroidApkUri,
        mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $downloadAndroidApkUri');
    }
  }

  Future<void> launchVisitGitHubRepoUrl() async {
    if (!await launchUrl(visitGitHubRepoUri,
        mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $visitGitHubRepoUri');
    }
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
          status = value['status'];
        } else {
          isUpdateAvailable = false;
          newVersion = currentVersion;
          status = value['status'];
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
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
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

  Future<List<ChangelogModel>> fetchChangelog() async {
    final androidUrl = Uri.parse(
        'https://raw.githubusercontent.com/stanlysilas/bloom_data/refs/heads/main/changelogs/android_changelog.json');
    http.Response response = await http.get(androidUrl);

    if (defaultTargetPlatform == TargetPlatform.android) {
      response = await http.get(androidUrl);
    }

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => ChangelogModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load changelog');
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
        title: const Text('About Bloom',
            style: TextStyle(
                fontFamily: 'ClashGrotesk', fontWeight: FontWeight.w500)),
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
                                fontFamily: 'ClashGrotesk',
                                fontSize: 20,
                                fontWeight: FontWeight.w400),
                          ),
                          // Version+BuildNumber
                          Text("Version $currentVersion"),
                          // Channel of the app update
                          // Text(!kIsWeb ? 'Beta Channel' : 'Web Client'),
                          // Stable or which beta iteration
                          Text("Channel: $status"),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // ChangeLog Block
                FutureBuilder<List<ChangelogModel>>(
                  future: fetchChangelog(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                          width: double.maxFinite,
                          margin: EdgeInsets.symmetric(horizontal: 14),
                          padding: EdgeInsets.all(14),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainer),
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(year2023: false));
                    } else if (snapshot.hasError) {
                      print(snapshot.error);
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "Couldn't load changelog. Please try again later.",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    final changelogs = snapshot.data ?? [];
                    final currentVersionLog = changelogs.firstWhere(
                      (log) => log.version == currentVersion,
                      orElse: () => ChangelogModel(
                        version: currentVersion,
                        title: "No changelog available",
                        date: "",
                        highlights: [],
                        notes: "",
                      ),
                    );
                    return Container(
                      width: double.maxFinite,
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      padding: const EdgeInsets.all(14.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            currentVersionLog.title,
                            style: TextStyle(
                              fontFamily: 'ClashGrotesk',
                              fontWeight: FontWeight.w400,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Version + Date
                          currentVersionLog.date.isNotEmpty
                              ? Text("Released on ${currentVersionLog.date}")
                              : Text("Changelog unavailable for this version"),
                          const SizedBox(height: 12),
                          // Highlights (bullet points)
                          if (currentVersionLog.highlights.isNotEmpty)
                            ...currentVersionLog.highlights
                                .map((item) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text("• "),
                                          Expanded(child: Text(item)),
                                        ],
                                      ),
                                    )),
                          // Notes section
                          if (currentVersionLog.notes.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              "Notes",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            Text(currentVersionLog.notes),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Check for updates button for Android
                kIsWeb == false
                    ? BloomMaterialListTile(
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
                      )
                    : BloomMaterialListTile(
                        borderRadius: BorderRadius.circular(24),
                        icon: const Icon(Icons.download),
                        label: "Download Android APK",
                        subLabel:
                            'Download and use the Android version for the full experience',
                        // showTag: isUpdateAvailable,
                        // tagIcon: const Icon(
                        //   Icons.new_releases,
                        //   size: 14,
                        // ),
                        // tagLabel: 'Update available',
                        innerPadding: const EdgeInsets.all(12),
                        onTap: launchDownloadAndroidApkUrl,
                      ),
                const SizedBox(height: 16),
                // GitHub repo Button
                BloomMaterialListTile(
                  borderRadius: BorderRadius.circular(24),
                  icon: const Icon(Icons.open_in_browser),
                  label: 'View on GitHub',
                  subLabel: 'Visit the GitHub repository for Bloom',
                  // showTag: isUpdateAvailable,
                  // tagIcon: const Icon(
                  //   Icons.new_releases,
                  //   size: 14,
                  // ),
                  // tagLabel: 'Update available',
                  innerPadding: const EdgeInsets.all(12),
                  onTap: launchVisitGitHubRepoUrl,
                )
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
