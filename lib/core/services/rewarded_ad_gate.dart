import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_your_hand/core/premium/premium_service.dart';

import '../../l10n/app_localizations.dart';
import 'ad_manger.dart';

/// Rewarded ad gate for premium-style actions (PDF preview/print, spreadsheet
/// import, voice orders, etc.). One completed reward runs the action once and
/// grants one spare use before another ad is required.
class RewardedAdGate {
  RewardedAdGate._();

  static const PremiumService _premium = PremiumService();

  static int _spareUses = 0;
  static RewardedAd? _preloaded;
  static bool _loadInFlight = false;

  static Future<void> preload() async {
    if (_premium.isPremiumSync) return;
    if (_preloaded != null || _loadInFlight) return;
    _loadInFlight = true;
    RewardedAd.load(
      adUnitId: AdManger.pdfRewardedAd,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _loadInFlight = false;
          if (_premium.isPremiumSync) {
            ad.dispose();
            return;
          }
          _preloaded = ad;
        },
        onAdFailedToLoad: (error) {
          _loadInFlight = false;
          debugPrint('RewardedAdGate preload failed: $error');
        },
      ),
    );
  }

  /// Runs [action] when the user has a spare use or after a completed rewarded ad.
  static Future<void> run(
    BuildContext context,
    FutureOr<void> Function() action,
  ) async {
    if (_premium.isPremiumSync) {
      await action();
      return;
    }
    if (_spareUses > 0) {
      _spareUses--;
      await action();
      unawaited(preload());
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
          unawaited(preload());
        },
        onAdFailedToShowFullScreenContent: (a, err) {
          debugPrint('RewardedAdGate show failed: $err');
          a.dispose();
          unawaited(preload());
          showLoadError();
        },
      );

      await ad.show(
        onUserEarnedReward: (ad, reward) {
          _spareUses = 1;
          unawaited(executeAction());
        },
      );
    }

    final cached = _preloaded;
    _preloaded = null;
    if (cached != null) {
      if (_premium.isPremiumSync) {
        cached.dispose();
        await action();
        return;
      }
      await present(cached);
      return;
    }

    RewardedAd.load(
      adUnitId: AdManger.pdfRewardedAd,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (loaded) async {
          if (_premium.isPremiumSync) {
            loaded.dispose();
            await executeAction();
            return;
          }
          await present(loaded);
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAdGate load failed: $error');
          showLoadError();
          unawaited(preload());
        },
      ),
    );
  }
}
