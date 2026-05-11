import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:in_your_hand/core/session/session_cubit.dart';
import 'package:in_your_hand/features/orders/data/order_model.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/orders_repository.dart';

part 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit({
    required OrdersRepository repository,
    required SessionCubit sessionCubit,
  })  : _repository = repository,
        _sessionCubit = sessionCubit,
        super(OrdersInitial()) {
    _sessionSub = _sessionCubit.stream.listen((state) {
      if (state is SessionLoaded) {
        _workspaceId = state.context.workspaceId;
        getOrders();
      }
    });
    final existing = _sessionCubit.contextOrNull;
    if (existing != null) {
      _workspaceId = existing.workspaceId;
      getOrders();
    }
  }

  final OrdersRepository _repository;
  final SessionCubit _sessionCubit;
  StreamSubscription? _sessionSub;
  String? _workspaceId;

  Future<void> addOrder(
    OrderModel order, {
    String creationMethod = 'manual',
  }) async {
    if (!order.isValidPayment) {
      emit(OrdersError(errorMessage: "Invalid payment values"));
      return;
    }
    emit(OrdersLoading());
    try {
      final wid = _workspaceId;
      if (wid == null) throw Exception('Session not ready');
      final id = order.id.isEmpty ? const Uuid().v4() : order.id;
      final now = DateTime.now();
      final entity = OrderEntity(
        id: id,
        workspaceId: wid,
        clientId: order.clientId,
        description: order.description,
        totalAmount: order.totalAmount,
        totalPaid: order.totalPaid,
        notes: order.notes,
        isDeleted: false,
        createdAt: order.createdAt,
        updatedAt: now,
        syncStatus: 1,
        remoteId: null,
      );
      await _repository.upsertOrder(entity);
      await FirebaseAnalytics.instance.logEvent(
        name: 'order_created',
        parameters: <String, Object>{
          'creation_method': creationMethod,
        },
      );
      await getOrders();
      // emit(AddingOrdersSuccess(
      //     successMessage: "Order added successfully"));
    } catch (e) {
      emit(OrdersError(errorMessage: e.toString()));
    }
  }

  Future<void> refreshAfterLocalDatabaseReset() => getOrders();

  Future<void> getOrders() async {
    emit(OrdersLoading());
    try {
      final wid = _workspaceId;
      if (wid == null) throw Exception('Session not ready');
      final entities = await _repository.listOrders(workspaceId: wid);
      final orders = entities
          .map(
            (e) => OrderModel(
              id: e.id,
              userId: e.workspaceId,
              clientId: e.clientId,
              description: e.description,
              totalAmount: e.totalAmount,
              totalPaid: e.totalPaid,
              notes: e.notes,
              createdAt: e.createdAt,
            ),
          )
          .toList(growable: false);
      emit(OrdersSuccess(orders: orders));
    } catch (e) {
      emit(OrdersError(errorMessage: e.toString()));
    }
  }

  Future<void> updateOrder(OrderModel order) async {
    emit(OrdersLoading());
    try {
      final wid = _workspaceId;
      if (wid == null) throw Exception('Session not ready');
      final now = DateTime.now();
      final entity = OrderEntity(
        id: order.id,
        workspaceId: wid,
        clientId: order.clientId,
        description: order.description,
        totalAmount: order.totalAmount,
        totalPaid: order.totalPaid,
        notes: order.notes,
        isDeleted: false,
        createdAt: order.createdAt,
        updatedAt: now,
        syncStatus: 1,
        remoteId: null,
      );
      await _repository.upsertOrder(entity);
      await getOrders();
    } catch (e) {
      emit(OrdersError(errorMessage: e.toString()));
    }
  }
  Future<void> updateOrderPayment(OrderModel order) async {
    // In offline-first mode, totalPaid updates are handled by upserting an
    // updated OrderEntity. The PaymentsCubit performs the atomic update.
    await updateOrder(order);
  }

  Future<void> deleteOrder(OrderModel order) async {
    emit(OrdersLoading());
    try {
      final wid = _workspaceId;
      if (wid == null) throw Exception('Session not ready');
      await _repository.softDeleteOrder(workspaceId: wid, id: order.id);
      await getOrders();
      // emit(AddingOrdersSuccess(
      //     successMessage: "Order deleted successfully"));
    } catch (e) {
      emit(OrdersError(errorMessage: e.toString()));
    }
  }


  Future<void> getClientOrders(String clientId) async {
    emit(OrdersLoading());
    try {
      final wid = _workspaceId;
      if (wid == null) throw Exception('Session not ready');
      final entities = await _repository.listOrdersByClient(
        workspaceId: wid,
        clientId: clientId,
      );
      final orders = entities
          .map(
            (e) => OrderModel(
              id: e.id,
              userId: e.workspaceId,
              clientId: e.clientId,
              description: e.description,
              totalAmount: e.totalAmount,
              totalPaid: e.totalPaid,
              notes: e.notes,
              createdAt: e.createdAt,
            ),
          )
          .toList(growable: false);
      emit(OrdersSuccess(orders: orders));
    } catch (e) {
      emit(OrdersError(errorMessage: e.toString()));
    }
  }

  Future<void> updateOrderNote(String orderId, String note) async {
    emit(OrdersLoading());
    try {
      if (state is OrdersSuccess) {
        final existing =
            (state as OrdersSuccess).orders.where((o) => o.id == orderId);
        final current = existing.isEmpty ? null : existing.first;
        if (current != null) {
          await updateOrder(
            OrderModel(
              id: current.id,
              userId: current.userId,
              clientId: current.clientId,
              description: current.description,
              totalAmount: current.totalAmount,
              totalPaid: current.totalPaid,
              notes: note,
              createdAt: current.createdAt,
            ),
          );
        }
      }
      await getOrders();
    } catch (e) {
      emit(OrdersError(errorMessage: e.toString()));
    }
  }

// Future<void> updateOrderStatus({
  //   required String orderId,
  //   required OrderStatus newStatus,
  // }) async {
  //   emit(OrdersLoading());
  //   try {
  //     await _firestore.collection('orders').doc(orderId).update({
  //       'status': newStatus.name,
  //     });
  //
  //     await getOrders();
  //     // emit(OrdersUpdatedSuccess());
  //   } catch (e) {
  //     emit(OrdersError(errorMessage: e.toString()));
  //   }
  // }

  @override
  Future<void> close() {
    _sessionSub?.cancel();
    return super.close();
  }
}
