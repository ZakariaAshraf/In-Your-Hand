import 'package:in_your_hand/core/premium/premium_ad_refresh_notifier.dart';
import 'package:in_your_hand/core/premium/revenuecat_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Subscription / entitlement via RevenueCat.
///
/// [isPremiumSync] reflects the last known state (updated in [init], [isPremium],
/// and via [Purchases.addCustomerInfoUpdateListener]) for instant ad / gate checks.
class PremiumService {
  const PremiumService();

  static bool _isPremiumCached = false;
  static bool _customerInfoListenerAttached = false;

  bool get isPremiumSync => _isPremiumCached;

  /// Call once after [RevenueCatService.init] so the cache matches entitlements
  /// before the first frame and stays in sync on CustomerInfo updates.
  static Future<void> init() async {
    try {
      _isPremiumCached = await RevenueCatService.instance.checkEntitlement();
    } catch (_) {
      _isPremiumCached = false;
    }

    if (!RevenueCatService.instance.isConfigured ||
        _customerInfoListenerAttached) {
      return;
    }
    _customerInfoListenerAttached = true;
    Purchases.addCustomerInfoUpdateListener((CustomerInfo info) {
      _isPremiumCached =
          info.entitlements.all[RevenueCatService.entitlementPremiumId]
                  ?.isActive ==
              true;
      PremiumAdRefreshNotifier.instance.notifyPremiumMayHaveChanged();
    });

    // try {
    //   final customerInfo = await Purchases.getCustomerInfo();
    //   print("==== 🕵️‍♂️ REVENUECAT DIAGNOSTIC ====");
    //   print("1. User ID: ${customerInfo.originalAppUserId}");
    //   print("2. Active Entitlements: ${customerInfo.entitlements.active.keys}");
    //   print("3. All Entitlements: ${customerInfo.entitlements.all.keys}");
    //   print("===================================");
    // } catch (e) {
    //   print("Error: $e");
    // }
  }

  /// Refreshes from RevenueCat and updates [isPremiumSync].
  Future<bool> isPremium() async {
    try {
      final v = await RevenueCatService.instance.checkEntitlement();
      _isPremiumCached = v;
      return v;
    } catch (_) {
      _isPremiumCached = false;
      return false;
    }
  }
}
