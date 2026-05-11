import '../../domain/entities/order_entity.dart';

abstract class OrdersRemoteDataSource {
  Future<void> upsertOrder(OrderEntity order);

  Future<List<OrderEntity>> listOrders({
    required String userId,
  });

  Future<List<OrderEntity>> listOrdersByClient({
    required String userId,
    required String clientId,
  });

  Future<void> softDeleteOrder({
    required String userId,
    required String id,
  });
}

