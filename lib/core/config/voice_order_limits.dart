/// Free-tier caps for voice orders (Gemini). Keep in sync with Firestore
/// `voiceOrdersUsed` / `voiceOrdersResetDate` and [VoiceOrderCubit].
class VoiceOrderLimits {
  VoiceOrderLimits._();

  /// Non-premium users get this many successful voice orders per rolling period
  /// before the backend resets the counter (see 30-day logic in [VoiceOrderCubit]).
  static const int freeVoiceOrdersPerPeriod = 1;
}
