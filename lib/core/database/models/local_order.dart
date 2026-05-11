import 'sync_status.dart';

class LocalOrder {
  final String id;
  final String workspaceId;
  final String clientId;
  final String description;
  final double totalAmount;
  final double totalPaid;
  final String? notes;
  final bool isDeleted;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? remoteId;

  const LocalOrder({
    required this.id,
    required this.workspaceId,
    required this.clientId,
    required this.description,
    required this.totalAmount,
    required this.totalPaid,
    this.notes,
    this.isDeleted = false,
    this.syncStatus = SyncStatus.pending,
    required this.createdAt,
    required this.updatedAt,
    this.remoteId,
  });

  factory LocalOrder.fromRow(Map<String, Object?> row) {
    return LocalOrder(
      id: row['id'] as String,
      workspaceId: row['workspace_id'] as String,
      clientId: row['client_id'] as String,
      description: row['description'] as String,
      totalAmount: (row['total_amount'] as num).toDouble(),
      totalPaid: (row['total_paid'] as num).toDouble(),
      notes: row['notes'] as String?,
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
      'client_id': clientId,
      'description': description,
      'total_amount': totalAmount,
      'total_paid': totalPaid,
      'notes': notes,
      'is_deleted': isDeleted ? 1 : 0,
      'sync_status': syncStatus.code,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'remote_id': remoteId,
    };
  }
}

