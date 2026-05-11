import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_local_data_source.dart';
import '../datasources/orders_remote_data_source.dart';
import '../mappers/order_mappers.dart';

class OfflineFirstOrdersRepository implements OrdersRepository {
  OfflineFirstOrdersRepository({
    required OrdersLocalDataSource local,
    required OrdersRemoteDataSource remote,
  })  : _local = local,
        _remote = remote;

  final OrdersLocalDataSource _local;
  // Injected for Phase 4; unused in Phase 1 by design.
  // ignore: unused_field
  final OrdersRemoteDataSource _remote;

  @override
  Future<void> upsertOrder(OrderEntity order) async {
    final local = OrderMappers.toLocal(
      order,
      updatedAtOverride: DateTime.now(),
    );
    await _local.upsertOrder(local);
  }

  @override
  Future<OrderEntity?> getOrderById({
    required String workspaceId,
    required String id,
  }) async {
    final local = await _local.getOrderById(workspaceId: workspaceId, id: id);
    if (local == null) return null;
    return OrderMappers.toEntity(local);
  }

  @override
  Future<List<OrderEntity>> listOrders({
    required String workspaceId,
    bool includeDeleted = false,
  }) async {
    final locals = await _local.listOrders(
      workspaceId: workspaceId,
      includeDeleted: includeDeleted,
    );
    return locals.map(OrderMappers.toEntity).toList(growable: false);
  }

  @override
  Future<List<OrderEntity>> listOrdersByClient({
    required String workspaceId,
    required String clientId,
    bool includeDeleted = false,
  }) async {
    final locals = await _local.listOrdersByClient(
      workspaceId: workspaceId,
      clientId: clientId,
      includeDeleted: includeDeleted,
    );
    return locals.map(OrderMappers.toEntity).toList(growable: false);
  }

  @override
  Future<void> softDeleteOrder({
    required String workspaceId,
    required String id,
  }) async {
    await _local.softDeleteOrder(workspaceId: workspaceId, id: id);
  }
}

