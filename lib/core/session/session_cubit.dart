import 'dart:async';

import 'package:bloc/bloc.dart';

import '../premium/revenuecat_service.dart';
import 'session_bootstrap.dart';
import 'session_context.dart';

part 'session_state.dart';

typedef AuthenticatedPendingUploadFn = Future<void> Function(String firebaseUid);

class SessionCubit extends Cubit<SessionState> {
  SessionCubit({
    AuthenticatedPendingUploadFn? onAuthenticatedPendingUpload,
  })  : _onAuthenticatedPendingUpload = onAuthenticatedPendingUpload,
        super(const SessionLoading()) {
    init();
  }

  final AuthenticatedPendingUploadFn? _onAuthenticatedPendingUpload;

  void _schedulePendingUpload(SessionContext context) {
    final fn = _onAuthenticatedPendingUpload;
    if (fn == null || !context.isAuthenticated) return;
    final uid = context.workspaceId;
    unawaited(
      Future<void>(() async {
        try {
          await fn(uid);
        } catch (_) {}
      }),
    );
  }

  Future<void> init() async {
    try {
      final context = await SessionBootstrap.load();
      emit(SessionLoaded(context));
      unawaited(RevenueCatService.instance.syncWithWorkspace(context.workspaceId));
      _schedulePendingUpload(context);
    } catch (e) {
      emit(SessionFailure(e.toString()));
    }
  }

  /// Ensure we are in Guest mode. Used by the \"Continue as Guest\" button.
  Future<void> ensureGuest() async {
    try {
      final guest = await SessionBootstrap.loadGuest();
      emit(SessionLoaded(guest));
      unawaited(RevenueCatService.instance.syncWithWorkspace(guest.workspaceId));
    } catch (e) {
      emit(SessionFailure(e.toString()));
    }
  }

  /// Re-evaluate session from FirebaseAuth / local workspace.
  /// Call this after login/logout so dependents (repositories/cubits) react.
  Future<void> refresh() async {
    await init();
  }

  SessionContext? get contextOrNull =>
      state is SessionLoaded ? (state as SessionLoaded).context : null;
}

