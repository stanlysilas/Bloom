import 'package:bloom/components/mybuttons.dart';
import 'package:bloom/components/rating_dialog.dart';
import 'package:bloom/responsive/dimensions.dart';
import 'package:bloom/screens/custom_templates_screen.dart';
// import 'package:bloom/screens/display_pomodoro_screen.dart';
import 'package:bloom/screens/profile_screen.dart';
import 'package:bloom/screens/settings_screen.dart';
import 'package:bloom/theme/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoreOptionsScreen extends StatefulWidget {
  const MoreOptionsScreen({super.key});

  @override
  State<MoreOptionsScreen> createState() => _MoreOptionsScreenState();
}

class _MoreOptionsScreenState extends State<MoreOptionsScreen> {
// Rretrieving the UserId
  final User? user = FirebaseAuth.instance.currentUser;
  String? profilePicUrl;
  String? email;
  String? userName;
  String? font;
  bool? isImageNetwork;
  late BannerAd bannerAd;
  bool isAdLoaded = false;
  bool? didRateApp;
  String? subscriptionPlan;

  @override
  void initState() {
    super.initState();
    // Fetch profile picture URL from Firestore
    fetchUserData();
    // Check for the font applied now
    fontCheck();
    // initBannerAd();
    checkUserRating();
  }

// Banner ADs initialization method
  initBannerAd() {
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: "ca-app-pub-5607290715305671/2817997384",
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

  // Check if the user has rated the app or not
  void checkUserRating() async {
    await FirebaseFirestore.instance
        .collection('ratings')
        .doc(user?.uid)
        .get()
        .then((value) async {
      if (value.exists && value.data()!.containsKey('userRating')) {
        setState(() {
          didRateApp = true;
        });
      } else if (value.id.isEmpty &&
          value.data()!.containsKey('userRating') == false) {
        setState(() {
          didRateApp = false;
        });
      } else {
        setState(() {
          didRateApp = false;
        });
      }
    });
  }

  // Check font method
  void fontCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final fontCheck = prefs.getString('font') ?? 'ClashGrotesk';
    setState(() {
      font = fontCheck;
    });
  }

  void fetchUserData() async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('users').doc(user?.uid);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();

        setState(() {
          profilePicUrl = data?['profilePicture'];
          email = data?['email'];
          userName = data?['userName'];
          isImageNetwork = data?['isImageNetwork'];

          // Check subscription plan
          final plan = data?['subscriptionPlan'];
          if (plan == null || plan == 'free') {
            subscriptionPlan = 'free';
          } else if (plan == 'pro') {
            subscriptionPlan = 'pro';
          } else {
            subscriptionPlan = 'ultra';
          }
        });
      }
    } catch (e) {
      //
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'More',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: MediaQuery.of(context).size.width < mobileWidth
                ? const EdgeInsets.all(0)
                : const EdgeInsets.symmetric(horizontal: 250),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                // More Features Category Heading
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Features',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                // Templates button
                ExtraOptionsButton(
                  showTag: subscriptionPlan == 'free' ? true : false,
                  icon: Image.asset(
                    themeProvider.theme == 'dark'
                        ? 'assets/custom_icons/templates_dark.png'
                        : themeProvider.theme == 'light'
                            ? 'assets/custom_icons/templates_light.png'
                            : WidgetsBinding.instance.platformDispatcher
                                        .platformBrightness ==
                                    Brightness.dark
                                ? 'assets/custom_icons/templates_dark.png'
                                : 'assets/custom_icons/templates_light.png',
                    scale: 22,
                  ),
                  label: 'Templates',
                  iconLabelSpace: 8,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16),
                  innerPadding: const EdgeInsets.all(12),
                  onTap: () {
                    if (subscriptionPlan == 'pro' ||
                        subscriptionPlan == 'ultra') {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const CustomTemplatesScreen()));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          margin: const EdgeInsets.all(6),
                          behavior: SnackBarBehavior.floating,
                          showCloseIcon: true,
                          backgroundColor: Theme.of(context).primaryColor,
                          closeIconColor:
                              Theme.of(context).textTheme.bodyMedium?.color,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          content: Text(
                            'Templates are only available with Pro and Ultra subscriptions',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color),
                          ),
                        ),
                      );
                    }
                  },
                  endIcon: const Icon(Iconsax.arrow_right),
                ),
                // const SizedBox(
                //   height: 10,
                // ),
                // // Pomodoro screen
                // ExtraOptionsButton(
                //   showTag: subscriptionPlan == 'free' ? true : false,
                //   icon: const Icon(Icons.timer_outlined),
                //   label: 'Pomodoro',
                //   iconLabelSpace: 8,
                //   labelStyle: const TextStyle(
                //       fontWeight: FontWeight.w600, fontSize: 16),
                //   innerPadding: const EdgeInsets.all(12),
                //   onTap: () {
                //     if (subscriptionPlan == 'pro' ||
                //         subscriptionPlan == 'ultra') {
                //       Navigator.of(context).push(MaterialPageRoute(
                //           builder: (context) => const DisplayPomodoroScreen()));
                //     } else {
                //       ScaffoldMessenger.of(context).showSnackBar(
                //         SnackBar(
                //           margin: const EdgeInsets.all(6),
                //           behavior: SnackBarBehavior.floating,
                //           showCloseIcon: true,
                //           backgroundColor: Theme.of(context).primaryColor,
                //           closeIconColor:
                //               Theme.of(context).textTheme.bodyMedium?.color,
                //           shape: RoundedRectangleBorder(
                //               borderRadius: BorderRadius.circular(12)),
                //           content: Text(
                //             'Pomodoro is only available with Pro and Ultra subscriptions',
                //             style: TextStyle(
                //                 color: Theme.of(context)
                //                     .textTheme
                //                     .bodyMedium
                //                     ?.color),
                //           ),
                //         ),
                //       );
                //     }
                //   },
                //   endIcon: const Icon(Iconsax.arrow_right),
                // ),
                const SizedBox(
                  height: 10,
                ),
                // More Features Category Heading
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'General',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                // Account
                ExtraOptionsButton(
                  icon: const Icon(Iconsax.personalcard),
                  label: 'Profile',
                  iconLabelSpace: 8,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16),
                  innerPadding: const EdgeInsets.all(12),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ProfileScreen(
                            isImageNetwork: isImageNetwork,
                            profilePicture: profilePicUrl,
                            userName: userName == '' || userName == null
                                ? user!.email!.substring(0, 8)
                                : userName,
                            uid: user!.uid,
                            email: email,
                            mode: ProfileMode.display,
                          ))),
                  endIcon: const Icon(Iconsax.arrow_right),
                ),
                const SizedBox(
                  height: 10,
                ),
                // Settings
                ExtraOptionsButton(
                  icon: const Icon(Iconsax.setting),
                  label: 'Settings',
                  iconLabelSpace: 8,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16),
                  innerPadding: const EdgeInsets.all(12),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => SettingsPage(
                            font: font ?? 'ClashGrotesk',
                          ))),
                  endIcon: const Icon(Iconsax.arrow_right),
                ),
                const SizedBox(
                  height: 10,
                ),
                // Subscription button
                // ExtraOptionsButton(
                //   icon: const Icon(Icons.back_hand_outlined),
                //   label: 'Get rid of ADs!',
                //   iconLabelSpace: 8,
                //   labelStyle: const TextStyle(
                //       fontWeight: FontWeight.w600, fontSize: 16),
                //   innerPadding: const EdgeInsets.all(12),
                //   onTap: () {
                //     // Display the subscription plans or redirect to the website or elsewhere for payment or plan info
                //     // For now display a snackbar indicating plan introductions in future
                //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                //         margin: const EdgeInsets.all(6),
                //         behavior: SnackBarBehavior.floating,
                //         showCloseIcon: true,
                //         backgroundColor: Theme.of(context).primaryColor,
                //         shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(12)),
                //         content: Text(
                //           'Subscription plans will be available soon to eliminate ADs.',
                //           style: TextStyle(
                //               color: Theme.of(context)
                //                   .textTheme
                //                   .bodyMedium
                //                   ?.color),
                //         )));
                //   },
                //   endIcon: const Icon(Iconsax.arrow_right),
                // ),
                // const SizedBox(
                //   height: 10,
                // ),
                // Button to rate the app, show only if the user hasn't rated yet
                if (didRateApp == false)
                  ExtraOptionsButton(
                    icon: const Icon(Iconsax.star),
                    iconLabelSpace: 8,
                    label: 'Rate Bloom!',
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16),
                    innerPadding: const EdgeInsets.all(12),
                    onTap: () {
                      // Show the app rating dialog box only if the user hasn't rated it yet
                      showAdaptiveDialog(
                          context: context,
                          builder: (context) {
                            return const RatingDialog();
                          });
                    },
                    endIcon: const Icon(Iconsax.arrow_right),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomSheet:
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
