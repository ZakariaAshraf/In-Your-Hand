/// Free-tier caps for AI voice orders (Gemini). Enforced locally per workspaceId via AiQuotaService.
class VoiceOrderLimits {
  VoiceOrderLimits._();

  /// Non-premium: successful voice-created orders allowed per calendar month (local prefs).
  static const int freeVoiceOrdersPerPeriod = 1;
}
