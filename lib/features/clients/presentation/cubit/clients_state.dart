part of 'clients_cubit.dart';

@immutable
sealed class ClientsState {}

final class ClientsInitial extends ClientsState {}
final class ClientsLoading extends ClientsState {}
// final class AddingClientSuccess extends ClientsState {
//   final String successMessage;
//
//   AddingClientSuccess({required this.successMessage});
// }
final class ClientsSuccess extends ClientsState {
  final List<ClientModel> clients;

  ClientsSuccess({required this.clients});
}
final class ClientsError extends ClientsState {
  final String errorMessage;

  ClientsError({required this.errorMessage});
}
