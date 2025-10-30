import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class ADService {
  // Initialize the GoogleADs method
  Future<void> initializeADS() async {
    try {
      // Initialize only if the platform is android or ios
      if (Platform.isAndroid || Platform.isIOS) {
        await MobileAds.instance.initialize();
      } else {}
    } catch (e) {
      //
    }
  }
}
