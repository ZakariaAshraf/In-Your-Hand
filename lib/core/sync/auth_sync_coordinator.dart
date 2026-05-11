import 'sync_engine.dart';

/// Post-login orchestration: runs [SyncEngine.runFullSync] then refreshes feature cubits.
final class AuthSyncCoordinator {
  AuthSyncCoordinator({required SyncEngine engine}) : _engine = engine;

  final SyncEngine _engine;
  Future<void> Function()? _refreshAllAfterSync;

  void attachRefreshAll(Future<void> Function() refreshAllAfterSync) {
    _refreshAllAfterSync = refreshAllAfterSync;
  }

  Future<void> runAuthenticatedFlow(String firebaseUid) async {
    var ran = false;
    try {
      ran = await _engine.runFullSync(firebaseUid);
    } catch (_) {}
    if (!ran) return;
    final r = _refreshAllAfterSync;
    if (r != null) {
      try {
        await r();
      } catch (_) {}
    }
  }
}
