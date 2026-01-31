import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpgradeSubscriptionScreen extends StatefulWidget {
  const UpgradeSubscriptionScreen({super.key});

  @override
  State<UpgradeSubscriptionScreen> createState() =>
      _UpgradeSubscriptionScreenState();
}

class _UpgradeSubscriptionScreenState extends State<UpgradeSubscriptionScreen> {
  // Required variables
  List planPrices = ['\$3.99', '\$12.99', '\$40.99'];
  List planTimePeriod = ['montly', 'yearly', 'lifetime'];
  int selectedPlanIndex = 0;
  final Uri pricingUri = Uri.parse('https://bloomproductive.framer.website/#pricing');
  final Uri privacyPolicyUri =
      Uri.parse('https://bloomproductive.framer.website/privacy-policy');
  final Uri reportAnIssueUri =
      Uri.parse('https://bloomproductive.framer.website/#contact');
  final Uri faqUri = Uri.parse('https://bloomproductive.framer.website/#faq');
  // Init method
  @override
  void initState() {
    super.initState();
    loadProFeatures();
  }

  // Load the Premium features JSON
  Future<Map<String, dynamic>> loadProFeatures() async {
    final data = await DefaultAssetBundle.of(context)
        .loadString('lib/required_data/profeatures.json');
    return json.decode(data);
  }

  // URL launcher methods
  Future<void> launchBloomWebsite(Uri uri, String type) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $type');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upgrade plan')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Text(
              'By upgrading to Bloom Pro, you can unlock additional features, have early access to new features and support the development of Bloom',
              style: TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: FutureBuilder<Map<String, dynamic>>(
              future: loadProFeatures(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(
                    year2023: false,
                    color: Theme.of(context).primaryColor,
                    backgroundColor: Theme.of(context).primaryColorLight,
                  ));
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text("Error loading feature list"));
                }

                final featureList = snapshot.data!;

                if (featureList.isEmpty) {
                  return const Center(child: Text("No feature list available"));
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...List.generate(
                      featureList["features"].length,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 4,
                          children: [
                            if (featureList['features'] != null)
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                              ),
                            if (featureList['features'] != null)
                              Expanded(
                                child: Text(
                                  featureList["features"][index],
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 250,
        color: Theme.of(context).primaryColorLight,
        child: Column(
          children: [
            Padding(
              padding:
                  EdgeInsetsGeometry.symmetric(vertical: 14, horizontal: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Buttons to choose the plan type (monthly, yearly or lifetime)
                  // Generate buttons by index for 3 plans
                  ...List.generate(
                    planPrices.length,
                    (index) => InkWell(
                      onTap: () {
                        // Change the selectedPlanIndex to indicate the selection by user
                        setState(() {
                          selectedPlanIndex = index;
                        });
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                        decoration: BoxDecoration(
                            color: selectedPlanIndex == index
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(15)),
                        child: Text(
                          "${planPrices[index]}/${planTimePeriod[index]}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // FAQ and Privacy Policy
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () => launchBloomWebsite(faqUri, 'FAQ'),
                    child: Text('FAQ')),
                TextButton(
                    onPressed: () =>
                        launchBloomWebsite(privacyPolicyUri, 'Privacy Policy'),
                    child: Text('Privacy Policy')),
                // TextButton(onPressed: () {}, child: Text('Restore Purchase')),
              ],
            ),
            const SizedBox(
              height: 14,
            ),
            // Upgrade the plan button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                width: double.maxFinite,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Theme.of(context).primaryColor),
                child: InkWell(
                  borderRadius: BorderRadius.circular(100),
                  // In-app-purchases functionality or Go to website (until the in-app-purchase is )
                  onTap: () => launchBloomWebsite(pricingUri, 'Subscriptions'),
                  child: Text(
                    'Upgrade to Pro',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
