import '../../domain/entities/client_entity.dart';
import '../../domain/repositories/clients_repository.dart';
import '../datasources/clients_local_data_source.dart';
import '../datasources/clients_remote_data_source.dart';
import '../mappers/client_mappers.dart';

class OfflineFirstClientsRepository implements ClientsRepository {
  OfflineFirstClientsRepository({
    required ClientsLocalDataSource local,
    required ClientsRemoteDataSource remote,
  })  : _local = local,
        _remote = remote;

  final ClientsLocalDataSource _local;
  // Injected for Phase 4; unused in Phase 1 by design.
  // ignore: unused_field
  final ClientsRemoteDataSource _remote;

  @override
  Future<void> upsertClient(ClientEntity client) async {
    final local = ClientMappers.toLocal(
      client,
      syncStatusOverride: null,
      updatedAtOverride: DateTime.now(),
    );
    await _local.upsertClient(local);
  }

  @override
  Future<ClientEntity?> getClientById({
    required String workspaceId,
    required String id,
  }) async {
    final local = await _local.getClientById(workspaceId: workspaceId, id: id);
    if (local == null) return null;
    return ClientMappers.toEntity(local);
  }

  @override
  Future<List<ClientEntity>> listClients({
    required String workspaceId,
    bool includeDeleted = false,
  }) async {
    final locals = await _local.listClients(
      workspaceId: workspaceId,
      includeDeleted: includeDeleted,
    );
    return locals.map(ClientMappers.toEntity).toList(growable: false);
  }

  @override
  Future<void> softDeleteClient({
    required String workspaceId,
    required String id,
  }) async {
    await _local.softDeleteClient(workspaceId: workspaceId, id: id);
  }
}

