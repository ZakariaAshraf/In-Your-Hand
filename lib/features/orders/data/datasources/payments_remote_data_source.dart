import '../../domain/entities/payment_entity.dart';

abstract class PaymentsRemoteDataSource {
  Future<void> upsertPayment(PaymentEntity payment);

  Future<List<PaymentEntity>> listPaymentsForOrder({
    required String orderId,
  });

  Future<void> softDeletePayment({
    required String orderId,
    required String id,
  });
}

