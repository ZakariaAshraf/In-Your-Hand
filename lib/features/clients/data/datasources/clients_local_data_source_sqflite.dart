import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/database/models/local_client.dart';
import '../../../../core/database/models/sync_status.dart';
import 'clients_local_data_source.dart';

class ClientsLocalDataSourceSqflite implements ClientsLocalDataSource {
  ClientsLocalDataSourceSqflite({DatabaseHelper? db})
      : _db = db ?? DatabaseHelper.instance;

  final DatabaseHelper _db;

  @override
  Future<void> upsertClient(LocalClient client) async {
    final Database database = await _db.database;
    await database.insert(
      DatabaseHelper.clientsTable,
      client.toRow(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<LocalClient?> getClientById({
    required String workspaceId,
    required String id,
  }) async {
    final Database database = await _db.database;
    final rows = await database.query(
      DatabaseHelper.clientsTable,
      where: 'workspace_id = ? AND id = ?',
      whereArgs: [workspaceId, id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return LocalClient.fromRow(rows.first);
  }

  @override
  Future<List<LocalClient>> listClients({
    required String workspaceId,
    bool includeDeleted = false,
  }) async {
    final Database database = await _db.database;
    final where = includeDeleted
        ? 'workspace_id = ?'
        : 'workspace_id = ? AND is_deleted = 0';
    final rows = await database.query(
      DatabaseHelper.clientsTable,
      where: where,
      whereArgs: [workspaceId],
      orderBy: 'created_at DESC',
    );
    return rows.map(LocalClient.fromRow).toList(growable: false);
  }

  @override
  Future<void> softDeleteClient({
    required String workspaceId,
    required String id,
  }) async {
    final Database database = await _db.database;
    await database.update(
      DatabaseHelper.clientsTable,
      <String, Object?>{
        'is_deleted': 1,
        'sync_status': 1,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'workspace_id = ? AND id = ?',
      whereArgs: [workspaceId, id],
    );
  }

  @override
  Future<List<LocalClient>> listPendingSync({
    required String workspaceId,
  }) async {
    final Database database = await _db.database;
    final rows = await database.query(
      DatabaseHelper.clientsTable,
      where: 'workspace_id = ? AND sync_status = ?',
      whereArgs: [workspaceId, SyncStatus.pending.code],
      orderBy: 'updated_at ASC',
    );
    return rows.map(LocalClient.fromRow).toList(growable: false);
  }

  @override
  Future<void> markSyncedAndRemapWorkspace({
    required String workspaceId,
    required String id,
    required String newWorkspaceId,
  }) async {
    final Database database = await _db.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await database.update(
      DatabaseHelper.clientsTable,
      <String, Object?>{
        'workspace_id': newWorkspaceId,
        'sync_status': SyncStatus.synced.code,
        'updated_at': now,
      },
      where: 'workspace_id = ? AND id = ?',
      whereArgs: [workspaceId, id],
    );
  }

  @override
  Future<void> deletePhysicalRow({
    required String workspaceId,
    required String id,
  }) async {
    final Database database = await _db.database;
    await database.delete(
      DatabaseHelper.clientsTable,
      where: 'workspace_id = ? AND id = ?',
      whereArgs: [workspaceId, id],
    );
  }
}

