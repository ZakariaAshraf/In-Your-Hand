part of 'session_cubit.dart';

sealed class SessionState {
  const SessionState();
}

final class SessionLoading extends SessionState {
  const SessionLoading();
}

final class SessionLoaded extends SessionState {
  const SessionLoaded(this.context);

  final SessionContext context;
}

final class SessionFailure extends SessionState {
  const SessionFailure(this.message);

  final String message;
}

