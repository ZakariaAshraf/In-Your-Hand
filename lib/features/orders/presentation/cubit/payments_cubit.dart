import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

import '../../data/payment_model.dart';

part 'payments_state.dart';

class PaymentsCubit extends Cubit<PaymentsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  PaymentsCubit() : super(PaymentsInitial());
  Future<void> addPayment({
    required String orderId,
    required double amount,
  }) async {
    emit(PaymentsLoading());

    try {
      final orderRef = _firestore.collection('orders').doc(orderId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(orderRef);

        final currentPaid =
        (snapshot.data()?['totalPaid'] ?? 0) as num;

        final newTotalPaid = currentPaid.toDouble() + amount;

        final totalAmount =
        (snapshot.data()?['totalAmount'] ?? 0) as num;

        if (newTotalPaid > totalAmount.toDouble()) {
          throw Exception("Payment exceeds total amount");
        }

        transaction.update(orderRef, {
          'totalPaid': newTotalPaid,
        });

        transaction.set(
          orderRef.collection('payments').doc(),
          {
            'amount': amount,
            'createdAt': Timestamp.now(),
          },
        );
      });
      // await getOrders();
      emit(PaymentsSuccess());
    } catch (e) {
      emit(PaymentsError(errorMessage: e.toString()));
    }
  }
  Future<void> loadPayments(String orderId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .doc(orderId)
          .collection('payments')
          .orderBy('createdAt', descending: true)
          .get();

      final payments = snapshot.docs
          .map((doc) => PaymentModel.fromFirestore(doc))
          .toList();

      emit(PaymentsLoaded(payments));
    } catch (e) {
      emit(PaymentsError(errorMessage: e.toString()));
    }
  }

}
