class ClientEntity {
  final String id;
  final String workspaceId;
  final String name;
  final String? phone;
  final String? notes;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int syncStatus; // 0 = synced, 1 = pending
  final String? remoteId;

  const ClientEntity({
    required this.id,
    required this.workspaceId,
    required this.name,
    this.phone,
    this.notes,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 1,
    this.remoteId,
  });
}

