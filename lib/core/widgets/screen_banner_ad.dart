import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Anchored adaptive banner for a detail screen. Collapses to zero height until loaded.
class ScreenBannerAd extends StatefulWidget {
  const ScreenBannerAd({super.key, required this.adUnitId});

  final String adUnitId;

  @override
  State<ScreenBannerAd> createState() => _ScreenBannerAdState();
}

class _ScreenBannerAdState extends State<ScreenBannerAd> {
  BannerAd? _banner;
  bool _loaded = false;
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requested) return;
    _requested = true;
    _loadBanner();
  }

  Future<void> _loadBanner() async {
    final width = MediaQuery.sizeOf(context).width.truncate();
    final size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    if (!mounted || size == null) return;

    BannerAd? ad;
    ad = BannerAd(
      adUnitId: widget.adUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (!mounted) return;
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
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
