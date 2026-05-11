sealed class SessionContext {
  const SessionContext();

  String get workspaceId;

  bool get isGuest => this is GuestSession;
  bool get isAuthenticated => this is AuthenticatedSession;
}

final class GuestSession extends SessionContext {
  const GuestSession({required this.workspaceId});

  @override
  final String workspaceId;
}

final class AuthenticatedSession extends SessionContext {
  const AuthenticatedSession({required this.workspaceId});

  /// For authenticated users, workspaceId == Firebase uid.
  @override
  final String workspaceId;
}

