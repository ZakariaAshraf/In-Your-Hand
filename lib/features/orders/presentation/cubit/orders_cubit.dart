import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:in_your_hand/features/orders/data/order_model.dart';
import 'package:meta/meta.dart';

import '../../data/payment_model.dart';

part 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit() : super(OrdersInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get userId => _auth.currentUser!.uid;

  Future<void> addOrder(OrderModel order) async {
    if (!order.isValidPayment) {
      emit(OrdersError(errorMessage: "Invalid payment values"));
      return;
    }
    emit(OrdersLoading());
    try {
      await _firestore.collection('orders').add(
        order.toFirestore(),
      );
      await getOrders();
      // emit(AddingOrdersSuccess(
      //     successMessage: "Order added successfully"));
    } catch (e) {
      emit(OrdersError(errorMessage: e.toString()));
    }
  }

  Future<void> getOrders() async {
    emit(OrdersLoading());
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          // .orderBy('createdAt', descending: true)
          .get();

      final orders = snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
      emit(OrdersSuccess(orders: orders));
    } catch (e) {
      emit(OrdersError(errorMessage: e.toString()));
    }
  }

  Future<void> updateOrder(OrderModel order) async {
    emit(OrdersLoading());
    try {
      await _firestore
          .collection('orders')
          .doc(order.id)
          .update(order.toFirestore());
      await getOrders();
    } catch (e) {
      emit(OrdersError(errorMessage: e.toString()));
    }
  }
  Future<void> updateOrderPayment(OrderModel order) async {
    emit(OrdersLoading());
    try {
      await _firestore
          .collection('orders')
          .doc(order.id)
          .update({
        // 'paidAmount': order.paidAmount,
      });
      await getOrders();
    } catch (e) {
      emit(OrdersError(errorMessage: e.toString()));
    }
  }

  Future<void> deleteOrder(OrderModel order) async {
    emit(OrdersLoading());
    try {
      await _firestore
          .collection('orders')
          .doc(order.id)
          .delete();
      await getOrders();
      // emit(AddingOrdersSuccess(
      //     successMessage: "Order deleted successfully"));
    } catch (e) {
      emit(OrdersError(errorMessage: e.toString()));
    }
  }


  getClientOrders(String clientId) async {
    emit(OrdersLoading());
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('clientId', isEqualTo: clientId)
      // .orderBy('createdAt', descending: true)
          .get();

      final orders = snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
      emit(OrdersSuccess(orders: orders));
    } catch (e) {
      emit(OrdersError(errorMessage: e.toString()));
    }
  }

  Future<void> updateOrderNote(String orderId, String note) async {
    emit(OrdersLoading());
    try {
      await _firestore
          .collection('orders')
          .doc(orderId)
          .update({
        'notes': note,
      });

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

}
