import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'pdf_rewarded_gate.dart';

/// Initializes the Mobile Ads SDK before any ad unit is requested.
///
/// Call once after [WidgetsFlutterBinding.ensureInitialized], before [runApp].
/// The Android manifest must declare `com.google.android.gms.ads.APPLICATION_ID`;
/// iOS must declare `GADApplicationIdentifier` in Info.plist (same AdMob app id).
Future<void> initializeMobileAds() async {
  final status = await MobileAds.instance.initialize();

  if (kDebugMode) {
    status.adapterStatuses.forEach((adapter, adapterStatus) {
      debugPrint(
        'MobileAds: $adapter → ${adapterStatus.state} (${adapterStatus.description})',
      );
    });
  }

  // Start loading the first rewarded ad only after the SDK reports ready.
  PdfRewardedGate.preload();
}
