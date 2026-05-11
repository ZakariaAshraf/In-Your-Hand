import '../../../../core/database/models/local_payment.dart';
import '../../../../core/database/models/sync_status.dart';
import '../../domain/entities/payment_entity.dart';

class PaymentMappers {
  PaymentMappers._();

  static PaymentEntity toEntity(LocalPayment model) {
    return PaymentEntity(
      id: model.id,
      workspaceId: model.workspaceId,
      orderId: model.orderId,
      amount: model.amount,
      isDeleted: model.isDeleted,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      syncStatus: model.syncStatus.code,
      remoteId: model.remoteId,
    );
  }

  static LocalPayment toLocal(
    PaymentEntity entity, {
    SyncStatus? syncStatusOverride,
    DateTime? updatedAtOverride,
  }) {
    return LocalPayment(
      id: entity.id,
      workspaceId: entity.workspaceId,
      orderId: entity.orderId,
      amount: entity.amount,
      isDeleted: entity.isDeleted,
      syncStatus: syncStatusOverride ?? SyncStatus.fromCode(entity.syncStatus),
      createdAt: entity.createdAt,
      updatedAt: updatedAtOverride ?? entity.updatedAt,
      remoteId: entity.remoteId,
    );
  }
}

