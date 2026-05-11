import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payments_repository.dart';
import '../datasources/payments_local_data_source.dart';
import '../datasources/payments_remote_data_source.dart';
import '../mappers/payment_mappers.dart';

class OfflineFirstPaymentsRepository implements PaymentsRepository {
  OfflineFirstPaymentsRepository({
    required PaymentsLocalDataSource local,
    required PaymentsRemoteDataSource remote,
  })  : _local = local,
        _remote = remote;

  final PaymentsLocalDataSource _local;
  // Injected for Phase 4; unused in Phase 1 by design.
  // ignore: unused_field
  final PaymentsRemoteDataSource _remote;

  @override
  Future<void> upsertPayment(PaymentEntity payment) async {
    final local = PaymentMappers.toLocal(
      payment,
      updatedAtOverride: DateTime.now(),
    );
    await _local.upsertPayment(local);
  }

  @override
  Future<List<PaymentEntity>> listPaymentsForOrder({
    required String workspaceId,
    required String orderId,
    bool includeDeleted = false,
  }) async {
    final locals = await _local.listPaymentsForOrder(
      workspaceId: workspaceId,
      orderId: orderId,
      includeDeleted: includeDeleted,
    );
    return locals.map(PaymentMappers.toEntity).toList(growable: false);
  }

  @override
  Future<void> softDeletePayment({
    required String workspaceId,
    required String id,
  }) async {
    await _local.softDeletePayment(workspaceId: workspaceId, id: id);
  }
}
