import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/database/models/local_payment.dart';
import '../../../../core/database/models/sync_status.dart';
import 'payments_local_data_source.dart';

class PaymentsLocalDataSourceSqflite implements PaymentsLocalDataSource {
  PaymentsLocalDataSourceSqflite({DatabaseHelper? db})
      : _db = db ?? DatabaseHelper.instance;

  final DatabaseHelper _db;

  @override
  Future<void> upsertPayment(LocalPayment payment) async {
    final Database database = await _db.database;
    await database.insert(
      DatabaseHelper.paymentsTable,
      payment.toRow(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<LocalPayment>> listPaymentsForOrder({
    required String workspaceId,
    required String orderId,
    bool includeDeleted = false,
  }) async {
    final Database database = await _db.database;
    final where = includeDeleted
        ? 'workspace_id = ? AND order_id = ?'
        : 'workspace_id = ? AND order_id = ? AND is_deleted = 0';
    final rows = await database.query(
      DatabaseHelper.paymentsTable,
      where: where,
      whereArgs: [workspaceId, orderId],
      orderBy: 'created_at DESC',
    );
    return rows.map(LocalPayment.fromRow).toList(growable: false);
  }

  @override
  Future<void> softDeletePayment({
    required String workspaceId,
    required String id,
  }) async {
    final Database database = await _db.database;
    await database.update(
      DatabaseHelper.paymentsTable,
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
  Future<List<LocalPayment>> listPendingSync({
    required String workspaceId,
  }) async {
    final Database database = await _db.database;
    final rows = await database.query(
      DatabaseHelper.paymentsTable,
      where: 'workspace_id = ? AND sync_status = ?',
      whereArgs: [workspaceId, SyncStatus.pending.code],
      orderBy: 'updated_at ASC',
    );
    return rows.map(LocalPayment.fromRow).toList(growable: false);
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
      DatabaseHelper.paymentsTable,
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
      DatabaseHelper.paymentsTable,
      where: 'workspace_id = ? AND id = ?',
      whereArgs: [workspaceId, id],
    );
  }
}

