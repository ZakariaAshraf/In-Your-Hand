import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/database/models/local_order.dart';
import '../../../../core/database/models/sync_status.dart';
import 'orders_local_data_source.dart';

class OrdersLocalDataSourceSqflite implements OrdersLocalDataSource {
  OrdersLocalDataSourceSqflite({DatabaseHelper? db})
      : _db = db ?? DatabaseHelper.instance;

  final DatabaseHelper _db;

  @override
  Future<void> upsertOrder(LocalOrder order) async {
    final Database database = await _db.database;
    await database.insert(
      DatabaseHelper.ordersTable,
      order.toRow(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<LocalOrder?> getOrderById({
    required String workspaceId,
    required String id,
  }) async {
    final Database database = await _db.database;
    final rows = await database.query(
      DatabaseHelper.ordersTable,
      where: 'workspace_id = ? AND id = ?',
      whereArgs: [workspaceId, id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return LocalOrder.fromRow(rows.first);
  }

  @override
  Future<List<LocalOrder>> listOrders({
    required String workspaceId,
    bool includeDeleted = false,
  }) async {
    final Database database = await _db.database;
    final where =
        includeDeleted ? 'workspace_id = ?' : 'workspace_id = ? AND is_deleted = 0';
    final rows = await database.query(
      DatabaseHelper.ordersTable,
      where: where,
      whereArgs: [workspaceId],
      orderBy: 'created_at DESC',
    );
    return rows.map(LocalOrder.fromRow).toList(growable: false);
  }

  @override
  Future<List<LocalOrder>> listOrdersByClient({
    required String workspaceId,
    required String clientId,
    bool includeDeleted = false,
  }) async {
    final Database database = await _db.database;
    final where = includeDeleted
        ? 'workspace_id = ? AND client_id = ?'
        : 'workspace_id = ? AND client_id = ? AND is_deleted = 0';
    final rows = await database.query(
      DatabaseHelper.ordersTable,
      where: where,
      whereArgs: [workspaceId, clientId],
      orderBy: 'created_at DESC',
    );
    return rows.map(LocalOrder.fromRow).toList(growable: false);
  }

  @override
  Future<void> softDeleteOrder({
    required String workspaceId,
    required String id,
  }) async {
    final Database database = await _db.database;
    await database.update(
      DatabaseHelper.ordersTable,
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
  Future<List<LocalOrder>> listPendingSync({
    required String workspaceId,
  }) async {
    final Database database = await _db.database;
    final rows = await database.query(
      DatabaseHelper.ordersTable,
      where: 'workspace_id = ? AND sync_status = ?',
      whereArgs: [workspaceId, SyncStatus.pending.code],
      orderBy: 'updated_at ASC',
    );
    return rows.map(LocalOrder.fromRow).toList(growable: false);
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
      DatabaseHelper.ordersTable,
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
      DatabaseHelper.ordersTable,
      where: 'workspace_id = ? AND id = ?',
      whereArgs: [workspaceId, id],
    );
  }
}

