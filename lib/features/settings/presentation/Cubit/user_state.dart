part of 'user_cubit.dart';

@immutable
sealed class UserState {
  const UserState();
}

final class UserLoading extends UserState {
  const UserLoading();
}

final class UserLoaded extends UserState {
  const UserLoaded(this.profile);

  final BusinessProfile profile;
}

final class UserError extends UserState {
  const UserError(this.message);

  final String message;
}

