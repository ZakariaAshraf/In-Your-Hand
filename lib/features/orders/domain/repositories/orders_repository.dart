import '../entities/order_entity.dart';

abstract class OrdersRepository {
  Future<void> upsertOrder(OrderEntity order);

  Future<OrderEntity?> getOrderById({
    required String workspaceId,
    required String id,
  });

  Future<List<OrderEntity>> listOrders({
    required String workspaceId,
    bool includeDeleted = false,
  });

  Future<List<OrderEntity>> listOrdersByClient({
    required String workspaceId,
    required String clientId,
    bool includeDeleted = false,
  });

  Future<void> softDeleteOrder({
    required String workspaceId,
    required String id,
  });
}

