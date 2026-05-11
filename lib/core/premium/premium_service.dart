import 'package:in_your_hand/core/premium/revenuecat_service.dart';

/// Subscription / entitlement via RevenueCat ([RevenueCatService.checkEntitlement]).
class PremiumService {
  const PremiumService();

  Future<bool> isPremium() => RevenueCatService.instance.checkEntitlement();
}
