import '../../../../core/database/models/local_client.dart';

abstract class ClientsLocalDataSource {
  Future<void> upsertClient(LocalClient client);

  Future<LocalClient?> getClientById({
    required String workspaceId,
    required String id,
  });

  Future<List<LocalClient>> listClients({
    required String workspaceId,
    bool includeDeleted = false,
  });

  Future<void> softDeleteClient({
    required String workspaceId,
    required String id,
  });

  /// Rows with `sync_status` pending (`1`), newest first by `updated_at`.
  Future<List<LocalClient>> listPendingSync({
    required String workspaceId,
  });

  Future<void> markSyncedAndRemapWorkspace({
    required String workspaceId,
    required String id,
    required String newWorkspaceId,
  });

  Future<void> deletePhysicalRow({
    required String workspaceId,
    required String id,
  });
}

