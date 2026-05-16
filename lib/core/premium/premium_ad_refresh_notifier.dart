import 'package:flutter/foundation.dart';

/// Notified when RevenueCat [CustomerInfo] updates so ad widgets can re-check premium.
final class PremiumAdRefreshNotifier extends ChangeNotifier {
  PremiumAdRefreshNotifier._();
  static final PremiumAdRefreshNotifier instance = PremiumAdRefreshNotifier._();

  void notifyPremiumMayHaveChanged() => notifyListeners();
}
