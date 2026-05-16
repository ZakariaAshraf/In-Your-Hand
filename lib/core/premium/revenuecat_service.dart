import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// RevenueCat SDK wrapper: configure, identify by [workspaceId], offerings, purchase, restore.
class RevenueCatService {
  RevenueCatService._();
  static final RevenueCatService instance = RevenueCatService._();

  static const String entitlementPremiumId = 'In Your Hand Pro';

  bool _configured = false;
  String? _lastSyncedWorkspaceId;

  bool get isConfigured => _configured;

  /// Call once after [SessionBootstrap] has resolved [workspaceId].
  Future<void> init(String workspaceId) async {
    if (_configured) {
      await syncWithWorkspace(workspaceId);
      return;
    }
    try {
      await Purchases.setLogLevel(LogLevel.debug);
      await Purchases.configure(
        PurchasesConfiguration(dotenv.env['REVENUECAT_GOOGLE_KEY']!),
      );
      _configured = true;
    } catch (e, st) {
      debugPrint('RevenueCat configure failed: $e\n$st');
      return;
    }
    await syncWithWorkspace(workspaceId);
  }

  /// Call when [workspaceId] changes (e.g. guest ↔ signed-in) so purchases attach to the right user.
  Future<void> syncWithWorkspace(String workspaceId) async {
    if (!_configured) return;
    if (_lastSyncedWorkspaceId == workspaceId) return;
    try {
      await Purchases.logIn(workspaceId);
      _lastSyncedWorkspaceId = workspaceId;
    } catch (e, st) {
      debugPrint('RevenueCat logIn failed: $e\n$st');
    }
  }

  /// Current offerings from the RevenueCat dashboard (default offering → packages).
  Future<Offerings?> fetchOfferings() async {
    if (!_configured) return null;
    try {
      return await Purchases.getOfferings();
    } catch (e, st) {
      debugPrint('RevenueCat getOfferings failed: $e\n$st');
      return null;
    }
  }

  /// Returns whether [entitlementPremiumId] is active after a successful purchase.
  Future<bool> purchasePackage(Package package) async {
    if (!_configured) return false;
    final result = await Purchases.purchase(
      PurchaseParams.package(package),
    );
    return result.customerInfo.entitlements.all[entitlementPremiumId]?.isActive ==
        true;
  }

  /// Returns updated [CustomerInfo] or `null` on failure.
  Future<CustomerInfo?> restorePurchases() async {
    if (!_configured) return null;
    try {
      return await Purchases.restorePurchases();
    } catch (e, st) {
      debugPrint('RevenueCat restorePurchases failed: $e\n$st');
      return null;
    }
  }

  Future<bool> checkEntitlement() async {
    if (!_configured) return false;
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.all[entitlementPremiumId]?.isActive == true;
    } catch (e, st) {
      debugPrint('RevenueCat getCustomerInfo failed: $e\n$st');
      return false;
    }
  }

  static bool isUserCancelledPurchase(Object error) {
    if (error is! PlatformException) return false;
    return PurchasesErrorHelper.getErrorCode(error) ==
        PurchasesErrorCode.purchaseCancelledError;
  }

  static String? purchaseErrorMessage(Object error) {
    if (error is PlatformException) {
      return error.message ?? error.code;
    }
    return error.toString();
  }
}
