part of 'user_cubit.dart';

@immutable
sealed class UserState {}

final class UserInitial extends UserState {}
class UserLoading extends UserState {}

class UserLoaded extends UserState {
final AppUserModel user;

UserLoaded(this.user);
}
class UserSuccess extends UserState {}


class UserError extends UserState {
final String message;

UserError(this.message);
}