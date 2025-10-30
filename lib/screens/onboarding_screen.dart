import 'package:bloom/authentication_screens/signup_screen.dart';
import 'package:bloom/notifications/notification.dart';
import 'package:bloom/storage_permission.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Variables
  late PageController pageController;
  int currentPage = 0;
  double page = 0.0;
  bool showHome = false;
  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (page != 1.0)
            TextButton(
                onPressed: () {
                  pageController.animateToPage(4,
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeIn);
                  setState(() {
                    page = 1.0;
                  });
                },
                child: Text('Skip'))
        ],
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (value) {
          setState(() {
            currentPage = value;
            page = value / 4;
          });
        },
        children: [
          // First page - Welcoming Screen
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Welcome to', style: TextStyle(fontSize: 18)),
                  const Text(
                    'Bloom - Productive',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // Picture/Video of the relevant screen/s
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        alignment: Alignment.center,
                        child: const Image(
                            image: AssetImage(
                                'assets/welcome_screen_assets/os_1.png')),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                        "Ever wanted a dedicated Task manager, Event scheduler, Notebook  and much more in one app? Don't worry, Bloom has got you covered!",
                        textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
          ),
          // Second page - Feature Set introduction screen
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Easily Create and Schedule',
                      style: TextStyle(fontSize: 18)),
                  const Text(
                    'Tasks & Events',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // Picture/Video of the relevant screen/s
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        alignment: Alignment.center,
                        child: const Image(
                            image: AssetImage(
                                'assets/welcome_screen_assets/os_2.png')),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Stay on top of your schedule with Bloom! Manage your tasks and plan events effortlessly—all in one place to keep your productivity blooming.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Third page - The Notes and Entries screen
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('Write ', style: TextStyle(fontSize: 18)),
                        Text('down ', style: TextStyle(fontSize: 18)),
                        const Text(
                          'Notes',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(' and', style: TextStyle(fontSize: 18)),
                        Text(' format', style: TextStyle(fontSize: 18)),
                        Text(' with ', style: TextStyle(fontSize: 18)),
                        const Text(
                          'Rich Text Editing',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Picture/Video of the relevant screen/s
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        alignment: Alignment.center,
                        child: const Image(
                            image: AssetImage(
                                'assets/welcome_screen_assets/os_3.png')),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                        "Capture your thoughts effortlessly with Bloom's Notes & Entries feature. From quick memos to detailed journals, enjoy rich text editing options to format your notes just the way you like!",
                        textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
          ),
          // Fourth page - about cross device syncing between android and windows
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('Stay ', style: TextStyle(fontSize: 18)),
                        const Text(
                          'Connected',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(' on all your ', style: TextStyle(fontSize: 18)),
                        const Text(
                          'Devices',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Picture/Video of the relevant screen/s
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        alignment: Alignment.center,
                        child: const Image(
                            image: AssetImage(
                                'assets/welcome_screen_assets/os_4.png')),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                        "With cross-device sync everything is updated across all your devices—just log in and pick up where you left off!",
                        textAlign: TextAlign.center),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "*Other plaforms will be available soon.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Fifth page - requesting permissions and get started
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('Never', style: TextStyle(fontSize: 18)),
                        Text(' miss a ', style: TextStyle(fontSize: 18)),
                        const Text(
                          'Task',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Text(
                          ', Event',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(' or a ', style: TextStyle(fontSize: 18)),
                        const Text(
                          'Deadline',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Picture/Video of the relevant screen/s
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        alignment: Alignment.center,
                        child: const Image(
                            image: AssetImage(
                                'assets/welcome_screen_assets/os_5.png')),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Text(
                      "Bloom needs few permissions to function as intended",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.task_alt_rounded,
                        color: Colors.green,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        "To remind you of your Tasks",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 68.0),
                    child: Divider(),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        color: Colors.red,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        "To remind you of your Events",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 68.0),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.download,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        "To Download and Update automatically",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 68.0),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.more_horiz_rounded),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        "And much more!",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 85,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeIn,
                tween: Tween<double>(
                  begin: page,
                  end: page,
                ),
                builder: (context, value, _) => LinearProgressIndicator(
                  year2023: false,
                  stopIndicatorColor: Colors.transparent,
                  value: value,
                ),
              ),
            ),
            FilledButton(
              onPressed: () async {
                if (currentPage == 4) {
                  try {
                    // Request for notification and storage permission
                    bool granted;
                    // FIXME: CHECK IF THIS ACTUALLY WORKS AND SENDS NOTIFICATIONS ON WEB
                    if (!kIsWeb) {
                      granted = await NotificationService.init() &&
                          await StoragePermission.init();
                    } else {
                      granted = true;
                    }
                    if (granted) {
                      setState(() {
                        page = 2.0;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          margin: const EdgeInsets.all(6),
                          behavior: SnackBarBehavior.floating,
                          showCloseIcon: true,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          content: Text(
                            'Permission access denied. Bloom might not run as expected.',
                          )));
                    }
                    // Navigate to Login screen after requesting
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const SignupScreen()));
                    // Call the onComplete for proper state management
                    widget.onComplete();
                  } catch (e) {
                    //
                  }
                } else {
                  pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeIn);
                }
              },
              child: Text(currentPage == 4 ? 'Grant permission' : 'Next'),
            )
          ],
        ),
      ),
    );
  }
}
