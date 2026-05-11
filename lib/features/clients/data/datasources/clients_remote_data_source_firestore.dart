import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/client_entity.dart';
import 'clients_remote_data_source.dart';

class ClientsRemoteDataSourceFirestore implements ClientsRemoteDataSource {
  ClientsRemoteDataSourceFirestore({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _clients =>
      _firestore.collection('clients');

  @override
  Future<void> upsertClient(ClientEntity client) async {
    // Firestore IDs are strings; we store them in `id` for remote DTOs.
    await _clients.doc(client.id).set(
      <String, dynamic>{
        'userId': client.workspaceId, // NOTE: will be Firebase UID in sync phase
        'name': client.name,
        'phone': client.phone,
        'notes': client.notes,
        'isDeleted': client.isDeleted,
        'createdAt': Timestamp.fromDate(client.createdAt),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<List<ClientEntity>> listClients({required String userId}) async {
    final snap = await _clients.where('userId', isEqualTo: userId).get();
    return snap.docs.map((doc) {
      final data = doc.data();
      return ClientEntity(
        id: doc.id,
        // For remote data sources, we overload workspaceId with userId (Firebase UID).
        // Offline-first repos won’t call this in Phase 1.
        workspaceId: userId,
        name: (data['name'] as String?) ?? '',
        phone: data['phone'] as String?,
        notes: data['notes'] as String?,
        isDeleted: (data['isDeleted'] as bool?) ?? false,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: 0,
      );
    }).toList(growable: false);
  }

  @override
  Future<void> softDeleteClient({
    required String userId,
    required String id,
  }) async {
    await _clients.doc(id).set(<String, dynamic>{'isDeleted': true}, SetOptions(merge: true));
  }

  @override
  Future<void> deleteClientDocument({required String id}) async {
    await _clients.doc(id).delete();
  }
}

