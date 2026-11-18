import 'package:bloom/core/responsive/responsive_split_view.dart';
import 'package:bloom/features/auth/signup_screen.dart';
import 'package:bloom/features/onboarding/onboarding_page.dart';
import 'package:bloom/features/onboarding/onboarding_permissions.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;

  int _currentPage = 0;

  static const _pages = [
    OnboardingPageData(
      title: 'Welcome to',
      highlightedTitle: 'Bloom - Productive',
      description:
          'Ever wanted a dedicated Task manager, Event scheduler, Notebook '
          'and much more in one app? Bloom has got you covered.',
      imageAsset: 'assets/welcome_screen_assets/os_1.png',
      imageSemanticLabel: 'Bloom productivity dashboard',
    ),
    OnboardingPageData(
      title: 'Easily Create and Schedule',
      highlightedTitle: 'Tasks & Events',
      description:
          'Stay on top of your schedule with Bloom. Manage your tasks and '
          'plan events effortlessly, all in one place.',
      imageAsset: 'assets/welcome_screen_assets/os_2.png',
      imageSemanticLabel: 'Bloom tasks and events interface',
    ),
    OnboardingPageData(
      title: 'Write down and format with',
      highlightedTitle: 'Rich Text Editing',
      description:
          'Capture your thoughts effortlessly with Bloom Notes & Entries. '
          'From quick memos to detailed journals, format your notes exactly '
          'the way you want.',
      imageAsset: 'assets/welcome_screen_assets/os_3.png',
      imageSemanticLabel: 'Bloom rich text editor',
    ),
    OnboardingPageData(
      title: 'Stay Connected on all your',
      highlightedTitle: 'Devices',
      description:
          'With cross-device sync, everything is updated across your devices. '
          'Log in and pick up where you left off.',
      imageAsset: 'assets/welcome_screen_assets/os_4.png',
      imageSemanticLabel: 'Bloom synchronized across multiple devices',
      footnote: 'Other platforms will be available soon.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  void _skip() {
    _goToPage(_pages.length);
  }

  Future<void> _completeOnboarding() async {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const SignupScreen(),
      ),
    );

    widget.onComplete();
  }

  Widget _buildPage(OnboardingPageData data) {
    return ResponsiveSplitView(
      visual: Image.asset(
        data.imageAsset,
        semanticLabel: data.imageSemanticLabel,
        fit: BoxFit.contain,
        cacheWidth: 1400,
      ),
      content: OnboardingPage(data: data),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (_currentPage < _pages.length)
            TextButton(
              onPressed: _skip,
              child: const Text('Skip'),
            ),
        ],
      ),
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: _pages.length + 1,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            if (index == _pages.length) {
              return ResponsiveSplitView(
                visual: Image.asset(
                  'assets/welcome_screen_assets/os_5.png',
                  semanticLabel: 'Bloom reminders and notifications',
                  fit: BoxFit.contain,
                  cacheWidth: 1400,
                ),
                content: OnboardingPermissions(
                  onGranted: _completeOnboarding,
                ),
              );
            }

            return _buildPage(_pages[index]);
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Semantics(
                  label:
                      'Onboarding progress: ${_currentPage + 1} of ${_pages.length + 1}',
                  child: LinearProgressIndicator(
                    year2023: false,
                    value: (_currentPage + 1) / (_pages.length + 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const Spacer(),
              if (_currentPage > 0)
                IconButton.filled(
                  tooltip: 'Previous page',
                  onPressed: () => _goToPage(_currentPage - 1),
                  icon: const Icon(Icons.navigate_before_rounded),
                ),
              const SizedBox(width: 8),
              if (_currentPage < _pages.length)
                IconButton.filled(
                  tooltip: 'Next page',
                  onPressed: () => _goToPage(_currentPage + 1),
                  icon: const Icon(Icons.navigate_next_rounded),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
