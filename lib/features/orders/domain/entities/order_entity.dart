class OrderEntity {
  final String id;
  final String workspaceId;
  final String clientId;
  final String description;
  final double totalAmount;
  final double totalPaid;
  final String? notes;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int syncStatus; // 0 = synced, 1 = pending
  final String? remoteId;

  const OrderEntity({
    required this.id,
    required this.workspaceId,
    required this.clientId,
    required this.description,
    required this.totalAmount,
    required this.totalPaid,
    this.notes,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 1,
    this.remoteId,
  });
}

