import 'sync_status.dart';

class LocalPayment {
  final String id;
  final String workspaceId;
  final String orderId;
  final double amount;
  final bool isDeleted;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? remoteId;

  const LocalPayment({
    required this.id,
    required this.workspaceId,
    required this.orderId,
    required this.amount,
    this.isDeleted = false,
    this.syncStatus = SyncStatus.pending,
    required this.createdAt,
    required this.updatedAt,
    this.remoteId,
  });

  factory LocalPayment.fromRow(Map<String, Object?> row) {
    return LocalPayment(
      id: row['id'] as String,
      workspaceId: row['workspace_id'] as String,
      orderId: row['order_id'] as String,
      amount: (row['amount'] as num).toDouble(),
      isDeleted: (row['is_deleted'] as int? ?? 0) == 1,
      syncStatus: SyncStatus.fromCode(row['sync_status'] as int?),
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int? ?? 0),
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int? ?? 0),
      remoteId: row['remote_id'] as String?,
    );
  }

  Map<String, Object?> toRow() {
    return <String, Object?>{
      'id': id,
      'workspace_id': workspaceId,
      'order_id': orderId,
      'amount': amount,
      'is_deleted': isDeleted ? 1 : 0,
      'sync_status': syncStatus.code,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'remote_id': remoteId,
    };
  }
}

