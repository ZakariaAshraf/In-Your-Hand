import '../entities/payment_entity.dart';

abstract class PaymentsRepository {
  Future<void> upsertPayment(PaymentEntity payment);

  Future<List<PaymentEntity>> listPaymentsForOrder({
    required String workspaceId,
    required String orderId,
    bool includeDeleted = false,
  });

  Future<void> softDeletePayment({
    required String workspaceId,
    required String id,
  });
}

