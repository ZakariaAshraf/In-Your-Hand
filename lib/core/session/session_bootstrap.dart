import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../cache/cache_helper.dart';
import 'session_context.dart';

class SessionBootstrap {
  SessionBootstrap._();

  static const String _guestWorkspaceIdKey = 'guest_workspace_id';

  /// Workspace id persisted for guest offline data ([GuestSession.workspaceId]).
  /// Still present after login until cleared; sync uses this to locate rows to upload.
  static String? tryReadGuestWorkspaceId() {
    final v = CacheHelper.getString(key: _guestWorkspaceIdKey)?.trim();
    if (v == null || v.isEmpty) return null;
    return v;
  }

  static Future<SessionContext> load() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthenticatedSession(workspaceId: user.uid);
    }

    final existing =
        CacheHelper.getString(key: _guestWorkspaceIdKey)?.trim();
    if (existing != null && existing.isNotEmpty) {
      return GuestSession(workspaceId: existing);
    }

    final newId = const Uuid().v4();
    await CacheHelper.set(key: _guestWorkspaceIdKey, value: newId);
    return GuestSession(workspaceId: newId);
  }

  /// Force a Guest session even if a Firebase user exists.
  static Future<GuestSession> loadGuest() async {
    final existing =
        CacheHelper.getString(key: _guestWorkspaceIdKey)?.trim();
    if (existing != null && existing.isNotEmpty) {
      return GuestSession(workspaceId: existing);
    }

    final newId = const Uuid().v4();
    await CacheHelper.set(key: _guestWorkspaceIdKey, value: newId);
    return GuestSession(workspaceId: newId);
  }
}

