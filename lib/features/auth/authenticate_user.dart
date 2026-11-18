import "dart:async";

import "package:bloom/core/responsive/desktop_body.dart";
import "package:bloom/core/responsive/responsive_layout.dart";
import "package:bloom/features/auth/signup_screen.dart";
// import "package:bloom/features/home/widgets/show_updates_dialog.dart";
import "package:bloom/core/utils/loading_animation.dart";
import "package:bloom/core/responsive/mobile_body.dart";
import "package:bloom/features/onboarding/onboarding_screen.dart";
import "package:bloom/core/widgets/custom_title_bar.dart";
import "package:bloom/services/app/app_data_service.dart";
import "package:bloom/services/app/update_service.dart";
// import "package:bloom/services/firebase/notification.dart";
import "package:bloom/services/network/network_service.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class AuthenticateUser extends StatefulWidget {
  final bool showHome;
  const AuthenticateUser({super.key, required this.showHome});

  @override
  State<AuthenticateUser> createState() => _AuthenticateUserState();
}

class _AuthenticateUserState extends State<AuthenticateUser> {
  late bool showHome;
  Timer? _timer;
  final UpdateService updateService = UpdateService();
  final AppDataService appDataService = AppDataService();
  final NetworkService networkService = NetworkService();
  final authStateChanges = FirebaseAuth.instance.authStateChanges();

  @override
  void initState() {
    super.initState();
    showHome = widget.showHome;
    if (!kIsWeb) {
      _timer = Timer.periodic(
        const Duration(seconds: 10),
        (_) => networkService.connectionStream.listen(
          (online) {
            if (!mounted) return;

            if (!online) {
              networkService.showOfflineBanner(context);
            } else {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            }
          },
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // final isUpdateAvailable = await updateService.updateAvailable();
      final appData = await appDataService.fetchAppData();

      if (appData == null) return;

      // final updateCollectionId =
      //     "${appData.latestAndroidVersion}+${appData.buildNumberAndroid}";

      // if (showHome == true && FirebaseAuth.instance.currentUser != null) {
      //   await NotificationService.resyncActionNotifications();
      //   if (isUpdateAvailable == true) {
      //     await showDialog(
      //       context: context,
      //       barrierDismissible: false,
      //       builder: (_) =>
      //           UpdatesDialog(updatesCollectionId: updateCollectionId),
      //     );
      //   }
      // }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    networkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const BreathingLoader();
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final user = snapshot.data;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          extendBody: true,
          extendBodyBehindAppBar: true,
          appBar: AppBar(toolbarHeight: 0),
          resizeToAvoidBottomInset: false,
          body: Column(
            children: [
              if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows)
                const Customtitlebar(),
              Expanded(
                child: user == null
                    ? (showHome
                        ? const SignupScreen()
                        : OnboardingScreen(onComplete: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('showHome', true);

                            setState(() {
                              showHome = true;
                            });
                          }))
                    : SafeArea(
                        child: const ResponsiveLayout(
                            mobileBody: MobileBody(),
                            desktopBody: DesktopBody()),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
