part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSuccess extends AuthState {
  final UserEntity user;

  AuthSuccess({required this.user});
}

/// Google (or other) sign-in succeeded in Firebase, but there is no `users/{uid}` doc yet.
final class AuthNeedsOnboarding extends AuthState {
  final UserEntity user;

  AuthNeedsOnboarding({required this.user});
}

final class AuthFailure extends AuthState {
  final String error;

  AuthFailure(this.error);
}
