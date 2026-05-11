import '../../../../core/database/models/local_order.dart';

abstract class OrdersLocalDataSource {
  Future<void> upsertOrder(LocalOrder order);

  Future<LocalOrder?> getOrderById({
    required String workspaceId,
    required String id,
  });

  Future<List<LocalOrder>> listOrders({
    required String workspaceId,
    bool includeDeleted = false,
  });

  Future<List<LocalOrder>> listOrdersByClient({
    required String workspaceId,
    required String clientId,
    bool includeDeleted = false,
  });

  Future<void> softDeleteOrder({
    required String workspaceId,
    required String id,
  });

  Future<List<LocalOrder>> listPendingSync({
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

