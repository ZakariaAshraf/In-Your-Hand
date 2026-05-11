import '../../domain/entities/client_entity.dart';

abstract class ClientsRemoteDataSource {
  Future<void> upsertClient(ClientEntity client);

  Future<List<ClientEntity>> listClients({
    required String userId,
  });

  Future<void> softDeleteClient({
    required String userId,
    required String id,
  });

  /// Permanent document removal (used by sync upload for tombstones).
  Future<void> deleteClientDocument({required String id});
}

