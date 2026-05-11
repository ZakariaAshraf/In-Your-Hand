import '../../../../core/database/models/local_client.dart';
import '../../../../core/database/models/sync_status.dart';
import '../../domain/entities/client_entity.dart';

class ClientMappers {
  ClientMappers._();

  static ClientEntity toEntity(LocalClient model) {
    return ClientEntity(
      id: model.id,
      workspaceId: model.workspaceId,
      name: model.name,
      phone: model.phone,
      notes: model.notes,
      isDeleted: model.isDeleted,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      syncStatus: model.syncStatus.code,
      remoteId: model.remoteId,
    );
  }

  static LocalClient toLocal(
    ClientEntity entity, {
    SyncStatus? syncStatusOverride,
    DateTime? updatedAtOverride,
  }) {
    return LocalClient(
      id: entity.id,
      workspaceId: entity.workspaceId,
      name: entity.name,
      phone: entity.phone,
      notes: entity.notes,
      isDeleted: entity.isDeleted,
      syncStatus: syncStatusOverride ?? SyncStatus.fromCode(entity.syncStatus),
      createdAt: entity.createdAt,
      updatedAt: updatedAtOverride ?? entity.updatedAt,
      remoteId: entity.remoteId,
    );
  }
}

