part of 'orders_cubit.dart';

@immutable
sealed class OrdersState {}

final class OrdersInitial extends OrdersState {}
final class OrdersLoading  extends OrdersState {}
final class OrdersSuccess extends OrdersState {
  final List<OrderModel>orders;

  OrdersSuccess({required this.orders});
}
// final class OrdersUpdatedSuccess extends OrdersState {
// }
final class OrdersError extends OrdersState {
  final String errorMessage;

  OrdersError({required this.errorMessage});

}
// final class AddingOrdersSuccess extends OrdersState {
//   final String successMessage;
//
//   AddingOrdersSuccess({required this.successMessage});
//
// }
