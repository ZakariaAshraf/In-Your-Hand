import '../../../../core/database/models/local_order.dart';
import '../../../../core/database/models/sync_status.dart';
import '../../domain/entities/order_entity.dart';

class OrderMappers {
  OrderMappers._();

  static OrderEntity toEntity(LocalOrder model) {
    return OrderEntity(
      id: model.id,
      workspaceId: model.workspaceId,
      clientId: model.clientId,
      description: model.description,
      totalAmount: model.totalAmount,
      totalPaid: model.totalPaid,
      notes: model.notes,
      isDeleted: model.isDeleted,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      syncStatus: model.syncStatus.code,
      remoteId: model.remoteId,
    );
  }

  static LocalOrder toLocal(
    OrderEntity entity, {
    SyncStatus? syncStatusOverride,
    DateTime? updatedAtOverride,
  }) {
    return LocalOrder(
      id: entity.id,
      workspaceId: entity.workspaceId,
      clientId: entity.clientId,
      description: entity.description,
      totalAmount: entity.totalAmount,
      totalPaid: entity.totalPaid,
      notes: entity.notes,
      isDeleted: entity.isDeleted,
      syncStatus: syncStatusOverride ?? SyncStatus.fromCode(entity.syncStatus),
      createdAt: entity.createdAt,
      updatedAt: updatedAtOverride ?? entity.updatedAt,
      remoteId: entity.remoteId,
    );
  }
}

