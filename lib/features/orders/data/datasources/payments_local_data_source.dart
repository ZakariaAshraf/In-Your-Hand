import '../../../../core/database/models/local_payment.dart';

abstract class PaymentsLocalDataSource {
  Future<void> upsertPayment(LocalPayment payment);

  Future<List<LocalPayment>> listPaymentsForOrder({
    required String workspaceId,
    required String orderId,
    bool includeDeleted = false,
  });

  Future<void> softDeletePayment({
    required String workspaceId,
    required String id,
  });

  Future<List<LocalPayment>> listPendingSync({
    required String workspaceId,
  });

  Future<void> markSyncedAndRemapWorkspace({
    required String workspaceId,
    required String id,
    required String newWorkspaceId,
  });

  Future<void> deletePhysicalRow({
    required String workspaceId,
    required String id,
  });
}

