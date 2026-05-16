import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_your_hand/core/premium/premium_service.dart';

import 'ad_manger.dart';

/// Centralized ad entry points. All methods no-op when the user has Premium (RevenueCat).
abstract final class AdManager {
  static const PremiumService _premium = PremiumService();

  /// No-op for Premium; reserved for future preloading of banner pools.
  static Future<void> loadBannerAd() async {
    if (_premium.isPremiumSync) return;
  }

  /// No-op for Premium; reserved for teardown hooks.
  static Future<void> disposeBannerAds() async {
    if (_premium.isPremiumSync) return;
  }

  /// No-op for Premium; optional warm-up (currently unused).
  static Future<void> preloadInterstitialAd() async {
    if (_premium.isPremiumSync) return;
  }

  /// Shows a full-screen interstitial after a successful save flow (non-premium only).
  static Future<void> showInterstitialAd() async {
    if (_premium.isPremiumSync) return;

    final done = Completer<void>();

    void completeOnce() {
      if (!done.isCompleted) done.complete();
    }

    await InterstitialAd.load(
      adUnitId: AdManger.interstitialAfterSave,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          if (_premium.isPremiumSync) {
            ad.dispose();
            completeOnce();
            return;
          }
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd a) {
              a.dispose();
              completeOnce();
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd a, _) {
              a.dispose();
              completeOnce();
            },
          );
          ad.show();
        },
        onAdFailedToLoad: (LoadAdError error) {
          if (kDebugMode) {
            debugPrint('AdManager interstitial load failed: $error');
          }
          completeOnce();
        },
      ),
    );

    try {
      await done.future.timeout(const Duration(seconds: 45));
    } on TimeoutException {
      completeOnce();
    }
  }
}
