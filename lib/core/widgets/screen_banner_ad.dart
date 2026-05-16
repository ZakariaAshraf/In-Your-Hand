import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_your_hand/core/premium/premium_ad_refresh_notifier.dart';
import 'package:in_your_hand/core/premium/premium_service.dart';

/// Anchored adaptive banner for list / hub screens. Hidden entirely for Premium users.
class ScreenBannerAd extends StatefulWidget {
  const ScreenBannerAd({super.key, required this.adUnitId});

  final String adUnitId;

  @override
  State<ScreenBannerAd> createState() => _ScreenBannerAdState();
}

class _ScreenBannerAdState extends State<ScreenBannerAd> {
  static const PremiumService _premium = PremiumService();

  BannerAd? _banner;
  bool _loaded = false;
  bool _requested = false;

  @override
  void initState() {
    super.initState();
    PremiumAdRefreshNotifier.instance.addListener(_onPremiumMayHaveChanged);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _reconcilePremiumAndMaybeLoad());
  }

  @override
  void dispose() {
    PremiumAdRefreshNotifier.instance.removeListener(_onPremiumMayHaveChanged);
    _banner?.dispose();
    super.dispose();
  }

  void _onPremiumMayHaveChanged() => _reconcilePremiumAndMaybeLoad();

  void _reconcilePremiumAndMaybeLoad() {
    if (!mounted) return;
    if (_premium.isPremiumSync) {
      if (_banner != null) {
        _banner!.dispose();
        _banner = null;
      }
      _loaded = false;
      _requested = false;
      setState(() {});
      return;
    }
    if (!_requested) {
      _requested = true;
      _loadBanner();
    }
  }

  Future<void> _loadBanner() async {
    if (_premium.isPremiumSync) return;
    final width = MediaQuery.sizeOf(context).width.truncate();
    final size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    if (!mounted || size == null) return;
    if (_premium.isPremiumSync) return;

    BannerAd? ad;
    ad = BannerAd(
      adUnitId: widget.adUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (!mounted) return;
          if (_premium.isPremiumSync) {
            ad?.dispose();
            return;
          }
          setState(() {
            _banner = ad;
            _loaded = true;
          });
        },
        onAdFailedToLoad: (failedAd, err) {
          failedAd.dispose();
        },
      ),
    );
    ad.load();
  }

  @override
  Widget build(BuildContext context) {
    if (_premium.isPremiumSync) {
      return const SizedBox.shrink();
    }
    if (!_loaded || _banner == null) {
      return const SizedBox.shrink();
    }
    return SafeArea(
      top: false,
      child: Center(
        child: SizedBox(
          width: _banner!.size.width.toDouble(),
          height: _banner!.size.height.toDouble(),
          child: AdWidget(ad: _banner!),
        ),
      ),
    );
  }
}

/// Alias for product naming; same as [ScreenBannerAd].
typedef BannerAdWidget = ScreenBannerAd;
