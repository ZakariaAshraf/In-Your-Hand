import 'package:flutter/foundation.dart';

class AdManger {
  /// Google test units in debug; your real units in release/profile builds.
  /// This avoids shipping test ids in store builds if the flag is left wrong.
  static bool get isTest => kDebugMode;
  static String pdfRewardedAd = isTest
      ? "ca-app-pub-3940256099942544/5224354917"
      : "ca-app-pub-5907953906414563/2147269929";

  static String orderDetailsBanner = isTest
      ? "ca-app-pub-3940256099942544/9214589741"
      : "ca-app-pub-5907953906414563/8708808843";

  static String clientDetailsBanner = isTest
      ? "ca-app-pub-3940256099942544/9214589741"
      : "ca-app-pub-5907953906414563/7395727170";
}
