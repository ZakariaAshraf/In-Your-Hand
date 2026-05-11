import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:in_your_hand/core/session/session_cubit.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/order_entity.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../../domain/repositories/payments_repository.dart';
import '../../data/payment_model.dart';

part 'payments_state.dart';

class PaymentsCubit extends Cubit<PaymentsState> {
  PaymentsCubit({
    required PaymentsRepository paymentsRepository,
    required OrdersRepository ordersRepository,
    required SessionCubit sessionCubit,
  })  : _paymentsRepository = paymentsRepository,
        _ordersRepository = ordersRepository,
        _sessionCubit = sessionCubit,
        super(PaymentsInitial()) {
    _sessionSub = _sessionCubit.stream.listen((state) {
      if (state is SessionLoaded) {
        _workspaceId = state.context.workspaceId;
      }
    });
    final existing = _sessionCubit.contextOrNull;
    if (existing != null) _workspaceId = existing.workspaceId;
  }

  final PaymentsRepository _paymentsRepository;
  final OrdersRepository _ordersRepository;
  final SessionCubit _sessionCubit;
  StreamSubscription? _sessionSub;
  String? _workspaceId;
  Future<void> addPayment({
    required String orderId,
    required double amount,
  }) async {
    emit(PaymentsLoading());

    try {
      final wid = _workspaceId;
      if (wid == null) throw Exception('Session not ready');

      final order = await _ordersRepository.getOrderById(
        workspaceId: wid,
        id: orderId,
      );
      if (order == null) throw Exception('Order not found');

      final newTotalPaid = order.totalPaid + amount;
      if (newTotalPaid > order.totalAmount) {
        throw Exception("Payment exceeds total amount");
      }

      final now = DateTime.now();
      final paymentEntity = PaymentEntity(
        id: const Uuid().v4(),
        workspaceId: wid,
        orderId: orderId,
        amount: amount,
        isDeleted: false,
        createdAt: now,
        updatedAt: now,
        syncStatus: 1,
        remoteId: null,
      );
      await _paymentsRepository.upsertPayment(paymentEntity);

      final updatedOrder = OrderEntity(
        id: order.id,
        workspaceId: order.workspaceId,
        clientId: order.clientId,
        description: order.description,
        totalAmount: order.totalAmount,
        totalPaid: newTotalPaid,
        notes: order.notes,
        isDeleted: order.isDeleted,
        createdAt: order.createdAt,
        updatedAt: now,
        syncStatus: 1,
        remoteId: order.remoteId,
      );
      await _ordersRepository.upsertOrder(updatedOrder);
      emit(PaymentsSuccess());
    } catch (e) {
      emit(PaymentsError(errorMessage: e.toString()));
    }
  }
  void resetAfterLocalDatabaseReset() {
    emit(PaymentsInitial());
  }

  Future<void> loadPayments(String orderId) async {
    try {
      final wid = _workspaceId;
      if (wid == null) throw Exception('Session not ready');
      final entities = await _paymentsRepository.listPaymentsForOrder(
        workspaceId: wid,
        orderId: orderId,
      );
      final payments = entities
          .map(
            (e) => PaymentModel(
              id: e.id,
              amount: e.amount,
              createdAt: e.createdAt,
            ),
          )
          .toList(growable: false);

      emit(PaymentsLoaded(payments));
    } catch (e) {
      emit(PaymentsError(errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sessionSub?.cancel();
    return super.close();
  }
}
