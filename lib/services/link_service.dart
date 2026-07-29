import 'package:url_launcher/url_launcher.dart';

class LinkService {
  Future<void> openPrivacyPolicy() async {
    final Uri privacyPolicyUri =
        Uri.parse('https://bloomproductive.framer.website/privacy-policy');

    if (!await launchUrl(privacyPolicyUri,
        mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $privacyPolicyUri');
    }
  }
}
