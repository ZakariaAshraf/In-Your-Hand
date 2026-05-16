/// AI voice order caps (Gemini). Enforced locally per workspaceId via AiQuotaService.
class VoiceOrderLimits {
  VoiceOrderLimits._();

  /// Guest / non-premium: per calendar month (local prefs).
  static const int freeVoiceOrdersPerPeriod = 1;

  /// Premium (RevenueCat entitlement): higher monthly cap on the same local counter.
  static const int premiumVoiceOrdersPerPeriod = 15;
}
