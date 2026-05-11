import '../entities/client_entity.dart';

abstract class ClientsRepository {
  Future<void> upsertClient(ClientEntity client);

  Future<ClientEntity?> getClientById({
    required String workspaceId,
    required String id,
  });

  Future<List<ClientEntity>> listClients({
    required String workspaceId,
    bool includeDeleted = false,
  });

  Future<void> softDeleteClient({
    required String workspaceId,
    required String id,
  });
}

