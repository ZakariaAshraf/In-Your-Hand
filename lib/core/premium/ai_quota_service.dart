import 'package:shared_preferences/shared_preferences.dart';

/// Per-[workspaceId] calendar-month quota for Gemini voice parsing (offline-first freemium).
class AiQuotaService {
  AiQuotaService();

  static String _monthKey(String workspaceId) => 'ai_voice_month_$workspaceId';
  static String _countKey(String workspaceId) => 'ai_voice_usage_count_$workspaceId';

  static String _yearMonth(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';

  /// Resets persisted count when the calendar month changed; returns usage this month after sync.
  Future<int> _usageAfterMonthSync({
    required SharedPreferences prefs,
    required String workspaceId,
  }) async {
    final monthKey = _monthKey(workspaceId);
    final countKey = _countKey(workspaceId);
    final current = _yearMonth(DateTime.now());
    final storedMonth = prefs.getString(monthKey);
    var count = prefs.getInt(countKey) ?? 0;

    if (storedMonth != current) {
      count = 0;
      await prefs.setString(monthKey, current);
      await prefs.setInt(countKey, 0);
    }
    return count;
  }

  /// Returns whether another voice-AI completion is allowed this month for [workspaceId].
  Future<bool> canUseVoiceAi(String workspaceId, {int freeLimit = 1}) async {
    final prefs = await SharedPreferences.getInstance();
    final usage = await _usageAfterMonthSync(
      prefs: prefs,
      workspaceId: workspaceId,
    );
    return usage < freeLimit;
  }

  /// Call after the user completes a saved voice-created order ([confirmAndAddOrder] success path).
  Future<void> incrementVoiceAiUsage(String workspaceId) async {
    final prefs = await SharedPreferences.getInstance();
    final countKey = _countKey(workspaceId);
    final usage = await _usageAfterMonthSync(
      prefs: prefs,
      workspaceId: workspaceId,
    );
    await prefs.setInt(countKey, usage + 1);
  }
}
