part of 'payments_cubit.dart';

@immutable
sealed class PaymentsState {}

final class PaymentsInitial extends PaymentsState {}
final class PaymentsLoading extends PaymentsState {}
final class PaymentsSuccess extends PaymentsState {}
final class PaymentsLoaded extends PaymentsState {
  final List<PaymentModel> payments;
  PaymentsLoaded(this.payments);
}
final class PaymentsError extends PaymentsState {
  final String errorMessage;

  PaymentsError({required this.errorMessage});
}
