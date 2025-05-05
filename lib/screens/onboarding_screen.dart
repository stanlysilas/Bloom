import 'package:bloom/authentication_screens/signup_screen.dart';
import 'package:bloom/notifications/notification.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

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
          InkWell(
            onTap: () {
              pageController.animateToPage(4,
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeIn);
              setState(() {
                page = 1.0;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                currentPage == 4 ? '' : 'Skip',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (value) {
          setState(() {
            currentPage = value;
            page = value / 5;
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
                  Text('Welcome to',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          color: Theme.of(context).primaryColorDark)),
                  const Text(
                    'Bloom - Productive',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
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
                  const SizedBox(
                    height: 20,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Ever wanted a dedicated Task manager, Event scheduler and a Notebook at one place? Don't worry, Bloom has got you covered!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w300),
                    ),
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
                      style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).primaryColorDark)),
                  const Text(
                    'Tasks & Events',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
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
                  const SizedBox(
                    height: 20,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Stay on top of your schedule with Bloom! Manage your tasks and plan events effortlessly—all in one place to keep your productivity blooming.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w300),
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
                        Text('Write ',
                            style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).primaryColorDark)),
                        Text('down ',
                            style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).primaryColorDark)),
                        const Text(
                          'Notes',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(' and',
                            style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).primaryColorDark)),
                        Text(' format',
                            style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).primaryColorDark)),
                        Text(' with ',
                            style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).primaryColorDark)),
                        const Text(
                          'Rich Text Editing',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
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
                  const SizedBox(
                    height: 20,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Capture your thoughts effortlessly with Bloom's Notes & Entries feature. From quick memos to detailed journals, enjoy rich text editing options to format your notes just the way you like!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w300),
                    ),
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
                        Text('Stay ',
                            style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).primaryColorDark)),
                        const Text(
                          'Connected',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(' on all your ',
                            style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).primaryColorDark)),
                        const Text(
                          'Devices',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
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
                  const SizedBox(
                    height: 10,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "With cross-device sync everything is updated across Android and Windows—just log in and pick up where you left off!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w300),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "*Cross-device sync will be available in a future update.",
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
                        Text('Never',
                            style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).primaryColorDark)),
                        Text(' miss a ',
                            style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).primaryColorDark)),
                        const Text(
                          'Task',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          ', Event',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(' or a ',
                            style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).primaryColorDark)),
                        const Text(
                          'Deadline',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
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
                  const SizedBox(
                    height: 10,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Text(
                      "Bloom needs permission to send you notifications.",
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
                        "To remind you of your Tasks.",
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
                        Iconsax.calendar5,
                        color: Colors.red,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        "To remind you of your Events.",
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
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 26.0),
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
                  minHeight: 6,
                  value: value,
                  borderRadius: BorderRadius.circular(15),
                  color: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).primaryColorLight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(1000),
                onTap: () async {
                  if (currentPage == 4) {
                    try {
                      // Request for notification permission
                      final bool granted = await NotificationService.init();
                      if (granted) {
                        setState(() {
                          page = 2.0;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            margin: const EdgeInsets.all(6),
                            behavior: SnackBarBehavior.floating,
                            showCloseIcon: true,
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            content: Text(
                              'Notification access denied. You will not receive any reminders.',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color),
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
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(1000)),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Text(
                    currentPage == 4 ? 'Grant permission' : 'Next',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.labelMedium?.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
