class PaymentEntity {
  final String id;
  final String workspaceId;
  final String orderId;
  final double amount;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int syncStatus; // 0 = synced, 1 = pending
  final String? remoteId;

  const PaymentEntity({
    required this.id,
    required this.workspaceId,
    required this.orderId,
    required this.amount,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 1,
    this.remoteId,
  });
}

