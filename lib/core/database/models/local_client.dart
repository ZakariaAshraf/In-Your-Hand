import 'sync_status.dart';

class LocalClient {
  final String id;
  final String workspaceId;
  final String name;
  final String? phone;
  final String? notes;
  final bool isDeleted;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? remoteId;

  const LocalClient({
    required this.id,
    required this.workspaceId,
    required this.name,
    this.phone,
    this.notes,
    this.isDeleted = false,
    this.syncStatus = SyncStatus.pending,
    required this.createdAt,
    required this.updatedAt,
    this.remoteId,
  });

  factory LocalClient.fromRow(Map<String, Object?> row) {
    return LocalClient(
      id: row['id'] as String,
      workspaceId: row['workspace_id'] as String,
      name: row['name'] as String,
      phone: row['phone'] as String?,
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
      'name': name,
      'phone': phone,
      'notes': notes,
      'is_deleted': isDeleted ? 1 : 0,
      'sync_status': syncStatus.code,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'remote_id': remoteId,
    };
  }
}

