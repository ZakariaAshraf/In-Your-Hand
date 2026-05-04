import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../l10n/app_localizations.dart';
import 'ad_manger.dart';

/// Rewarded ads for PDF preview and print. One completed reward unlocks the
/// current action and grants one extra PDF action before another ad is required.
class PdfRewardedGate {
  PdfRewardedGate._();

  static int _sparePdfUses = 0;
  static RewardedAd? _preloaded;
  static bool _loadInFlight = false;

  static void preload() {
    if (_preloaded != null || _loadInFlight) return;
    _loadInFlight = true;
    RewardedAd.load(
      adUnitId: AdManger.pdfRewardedAd,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _loadInFlight = false;
          _preloaded = ad;
        },
        onAdFailedToLoad: (error) {
          _loadInFlight = false;
          debugPrint('PdfRewardedGate preload failed: $error');
        },
      ),
    );
  }

  /// Runs [action] when the user has a spare use or after a completed rewarded ad.
  static Future<void> run(
    BuildContext context,
    FutureOr<void> Function() action,
  ) async {
    if (_sparePdfUses > 0) {
      _sparePdfUses--;
      await action();
      preload();
      return;
    }

    final messenger = ScaffoldMessenger.maybeOf(context);
    final l10n = AppLocalizations.of(context)!;

    Future<void> executeAction() async {
      if (!context.mounted) return;
      await action();
    }

    void showLoadError() {
      if (!context.mounted) return;
      messenger?.showSnackBar(
        SnackBar(content: Text(l10n.adCouldNotLoad)),
      );
    }

    Future<void> present(RewardedAd ad) async {
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (a) {
          a.dispose();
          preload();
        },
        onAdFailedToShowFullScreenContent: (a, err) {
          debugPrint('PdfRewardedGate show failed: $err');
          a.dispose();
          preload();
          showLoadError();
        },
      );

      await ad.show(
        onUserEarnedReward: (ad, reward) {
          _sparePdfUses = 1;
          unawaited(executeAction());
        },
      );
    }

    final cached = _preloaded;
    _preloaded = null;
    if (cached != null) {
      await present(cached);
      return;
    }

    RewardedAd.load(
      adUnitId: AdManger.pdfRewardedAd,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (loaded) async {
          await present(loaded);
        },
        onAdFailedToLoad: (error) {
          debugPrint('PdfRewardedGate load failed: $error');
          showLoadError();
          preload();
        },
      ),
    );
  }
}
