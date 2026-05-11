import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/order_entity.dart';
import 'orders_remote_data_source.dart';

class OrdersRemoteDataSourceFirestore implements OrdersRemoteDataSource {
  OrdersRemoteDataSourceFirestore({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection('orders');

  @override
  Future<void> upsertOrder(OrderEntity order) async {
    await _orders.doc(order.id).set(
      <String, dynamic>{
        'userId': order.workspaceId, // NOTE: will be Firebase UID in sync phase
        'clientId': order.clientId,
        'description': order.description,
        'totalAmount': order.totalAmount,
        'totalPaid': order.totalPaid,
        'notes': order.notes,
        'createdAt': Timestamp.fromDate(order.createdAt),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<List<OrderEntity>> listOrders({required String userId}) async {
    final snap = await _orders.where('userId', isEqualTo: userId).get();
    return snap.docs.map((doc) {
      final data = doc.data();
      final total = (data['totalAmount'] ?? data['amount'] ?? 0) as num;
      final paid = (data['totalPaid'] ?? 0) as num;
      return OrderEntity(
        id: doc.id,
        workspaceId: userId,
        clientId: (data['clientId'] as String?) ?? '',
        description: (data['description'] as String?) ?? '',
        totalAmount: total.toDouble(),
        totalPaid: paid.toDouble(),
        notes: data['notes'] as String?,
        isDeleted: (data['isDeleted'] as bool?) ?? false,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: 0,
      );
    }).toList(growable: false);
  }

  @override
  Future<List<OrderEntity>> listOrdersByClient({
    required String userId,
    required String clientId,
  }) async {
    final snap = await _orders
        .where('userId', isEqualTo: userId)
        .where('clientId', isEqualTo: clientId)
        .get();
    return snap.docs.map((doc) {
      final data = doc.data();
      final total = (data['totalAmount'] ?? data['amount'] ?? 0) as num;
      final paid = (data['totalPaid'] ?? 0) as num;
      return OrderEntity(
        id: doc.id,
        workspaceId: userId,
        clientId: (data['clientId'] as String?) ?? '',
        description: (data['description'] as String?) ?? '',
        totalAmount: total.toDouble(),
        totalPaid: paid.toDouble(),
        notes: data['notes'] as String?,
        isDeleted: (data['isDeleted'] as bool?) ?? false,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: 0,
      );
    }).toList(growable: false);
  }

  @override
  Future<void> softDeleteOrder({
    required String userId,
    required String id,
  }) async {
    // Current Firestore schema deletes orders; for sync we will likely introduce
    // soft delete. This method is here for the Phase 4 shape.
    await _orders.doc(id).delete();
  }
}

