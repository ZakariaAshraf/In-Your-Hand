import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/payment_entity.dart';
import 'payments_remote_data_source.dart';

class PaymentsRemoteDataSourceFirestore implements PaymentsRemoteDataSource {
  PaymentsRemoteDataSourceFirestore({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<void> upsertPayment(PaymentEntity payment) async {
    final orderRef = _firestore.collection('orders').doc(payment.orderId);
    final paymentRef = orderRef.collection('payments').doc(payment.id);
    await paymentRef.set(
      <String, dynamic>{
        'amount': payment.amount,
        'createdAt': Timestamp.fromDate(payment.createdAt),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<List<PaymentEntity>> listPaymentsForOrder({
    required String orderId,
  }) async {
    final orderRef = _firestore.collection('orders').doc(orderId);
    final snap = await orderRef
        .collection('payments')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((doc) {
      final data = doc.data();
      return PaymentEntity(
        id: doc.id,
        workspaceId: '',
        orderId: orderId,
        amount: ((data['amount'] ?? 0) as num).toDouble(),
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: 0,
        isDeleted: false,
      );
    }).toList(growable: false);
  }

  @override
  Future<void> softDeletePayment({
    required String orderId,
    required String id,
  }) async {
    final orderRef = _firestore.collection('orders').doc(orderId);
    await orderRef.collection('payments').doc(id).delete();
  }
}

