import 'package:bloom/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionsBanner extends StatelessWidget {
  final bool isFreeUser;
  final DateTime currentDate;
  SubscriptionsBanner({
    super.key,
    required this.isFreeUser,
    required this.currentDate,
  });

  // Required variables
  final Uri bloomproductiveSite =
      Uri.parse('https://bloomproductive.wixsite.com/bloomproductive');

  Future<void> launchReportAnIssueUrl() async {
    if (!await launchUrl(bloomproductiveSite, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $bloomproductiveSite');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withAlpha(70),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(themeProvider.theme == 'dark'
                        ? 'assets/custom_icons/subscriptions_dark.png'
                        : themeProvider.theme == 'light'
                            ? 'assets/custom_icons/subscriptions_light.png'
                            : WidgetsBinding.instance.platformDispatcher
                                        .platformBrightness ==
                                    Brightness.dark
                                ? 'assets/custom_icons/subscriptions_dark.png'
                                : 'assets/custom_icons/subscriptions_light.png')),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          const Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upgrade my Plan!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                    'Adding a Habit? A Pomodoro? Upgrade now to the Pro or Ultra plans for more such productivity features to keep Blooming!'),
              ],
            ),
          ),
          // Icon to dismiss the banner
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () async {
                  // Dismiss the banner only for the particular day
                  await launchReportAnIssueUrl();
                },
                icon: const Icon(Icons.open_in_new_rounded),
              ),
            ],
          )
        ],
      ),
    );
  }
}
