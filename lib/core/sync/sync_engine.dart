import 'package:in_your_hand/core/database/models/sync_status.dart';
import 'package:in_your_hand/core/session/session_bootstrap.dart';
import 'package:in_your_hand/core/sync/sync_upload_result.dart';
import 'package:in_your_hand/features/clients/data/datasources/clients_local_data_source.dart';
import 'package:in_your_hand/features/business_profile/data/datasources/business_profile_remote_data_source.dart';
import 'package:in_your_hand/features/business_profile/domain/entities/business_profile.dart';
import 'package:in_your_hand/features/business_profile/domain/repositories/business_profile_repository.dart';
import 'package:in_your_hand/features/clients/data/datasources/clients_remote_data_source.dart';
import 'package:in_your_hand/features/clients/data/mappers/client_mappers.dart';
import 'package:in_your_hand/features/clients/domain/entities/client_entity.dart';
import 'package:in_your_hand/features/orders/data/datasources/orders_local_data_source.dart';
import 'package:in_your_hand/features/orders/data/datasources/orders_remote_data_source.dart';
import 'package:in_your_hand/features/orders/data/datasources/payments_local_data_source.dart';
import 'package:in_your_hand/features/orders/data/datasources/payments_remote_data_source.dart';
import 'package:in_your_hand/features/orders/data/mappers/order_mappers.dart';
import 'package:in_your_hand/features/orders/data/mappers/payment_mappers.dart';
import 'package:in_your_hand/features/orders/domain/entities/order_entity.dart';
import 'package:in_your_hand/features/orders/domain/entities/payment_entity.dart';

/// Upload pipeline: pushes pending local CRM rows to Firestore for the signed-in user.
///
/// Dependency-safe order:
/// 1) Clients (upserts only)
/// 2) Orders (upserts only)
/// 3) Payments (upserts + payment tombstones)
/// 4) Order tombstones
/// 5) Client tombstones
///
/// Pending rows are read per workspace partition: guest id from
/// [SessionBootstrap.tryReadGuestWorkspaceId] and [firebaseUid], so items remapped
/// after earlier steps are still processed.
///
/// Download ([downloadData]) writes remote rows locally with `sync_status` synced
/// and `workspace_id == firebaseUid` (Clients → Orders → Payments), then merges
/// business profile text from `users/{uid}` into prefs (logo path stays local).
class SyncEngine {
  SyncEngine({
    required ClientsLocalDataSource clientsLocal,
    required OrdersLocalDataSource ordersLocal,
    required PaymentsLocalDataSource paymentsLocal,
    required ClientsRemoteDataSource clientsRemote,
    required OrdersRemoteDataSource ordersRemote,
    required PaymentsRemoteDataSource paymentsRemote,
    required BusinessProfileRepository businessProfileRepository,
    required BusinessProfileRemoteDataSource businessProfileRemote,
  })  : _clientsLocal = clientsLocal,
        _ordersLocal = ordersLocal,
        _paymentsLocal = paymentsLocal,
        _clientsRemote = clientsRemote,
        _ordersRemote = ordersRemote,
        _paymentsRemote = paymentsRemote,
        _businessProfileRepository = businessProfileRepository,
        _businessProfileRemote = businessProfileRemote;

  final ClientsLocalDataSource _clientsLocal;
  final OrdersLocalDataSource _ordersLocal;
  final PaymentsLocalDataSource _paymentsLocal;
  final ClientsRemoteDataSource _clientsRemote;
  final OrdersRemoteDataSource _ordersRemote;
  final PaymentsRemoteDataSource _paymentsRemote;
  final BusinessProfileRepository _businessProfileRepository;
  final BusinessProfileRemoteDataSource _businessProfileRemote;

  bool _busy = false;

  /// Upload queued local changes, then replace/merge SQLite from Firestore.
  ///
  /// Uses a single lock for the whole run (do not nest [uploadPendingData] /
  /// [downloadData] inside without refactoring locks).
  ///
  /// Returns `true` if upload + download ran under the lock (`false` if busy or
  /// empty uid). Callers can use this to decide whether to refresh UI.
  Future<bool> runFullSync(String firebaseUid) async {
    if (firebaseUid.isEmpty) return false;
    if (!_tryAcquireLock()) return false;
    try {
      await _performUploadPendingData(firebaseUid);
      await _performDownloadData(firebaseUid);
      return true;
    } finally {
      _releaseLock();
    }
  }

  /// Cloud → SQLite: clients, then orders, then payments (FK-safe).
  Future<void> downloadData(String firebaseUid) async {
    if (firebaseUid.isEmpty) return;
    if (!_tryAcquireLock()) return;
    try {
      await _performDownloadData(firebaseUid);
    } finally {
      _releaseLock();
    }
  }

  /// [firebaseUid] is `AuthenticatedSession.workspaceId`.
  Future<SyncUploadResult> uploadPendingData(String firebaseUid) async {
    if (firebaseUid.isEmpty) {
      return const SyncUploadResult(failureMessages: ['Missing Firebase uid']);
    }
    if (!_tryAcquireLock()) {
      return const SyncUploadResult(
        failureMessages: [],
        skippedDueToConcurrency: true,
      );
    }
    try {
      return await _performUploadPendingData(firebaseUid);
    } finally {
      _releaseLock();
    }
  }

  Future<SyncUploadResult> _performUploadPendingData(String firebaseUid) async {
    final errors = <String>[];
    final guest = SessionBootstrap.tryReadGuestWorkspaceId();
    final localWs =
        (guest != null && guest.isNotEmpty) ? guest : firebaseUid;

    try {
      await _forPartitions(
        primary: localWs,
        uid: firebaseUid,
        runner: (ws) => _clientUpsertsForWorkspace(ws, firebaseUid, errors),
      );
      await _forPartitions(
        primary: localWs,
        uid: firebaseUid,
        runner: (ws) => _orderUpsertsForWorkspace(ws, firebaseUid, errors),
      );
      await _forPartitions(
        primary: localWs,
        uid: firebaseUid,
        runner: (ws) => _paymentsForWorkspace(ws, firebaseUid, errors),
      );
      await _forPartitions(
        primary: localWs,
        uid: firebaseUid,
        runner: (ws) => _orderDeletesForWorkspace(ws, firebaseUid, errors),
      );
      await _forPartitions(
        primary: localWs,
        uid: firebaseUid,
        runner: (ws) => _clientDeletesForWorkspace(ws, errors),
      );
      await _uploadBusinessProfileToFirestore(firebaseUid, errors);
    } catch (e, st) {
      errors.add('SyncEngine upload fatal: $e $st');
    }

    return SyncUploadResult(failureMessages: List.unmodifiable(errors));
  }

  Future<void> _uploadBusinessProfileToFirestore(
    String firebaseUid,
    List<String> errors,
  ) async {
    try {
      final bundle = await _resolveLocalProfilesForUid(firebaseUid);
      await _businessProfileRemote.upsertBusinessText(
        uid: firebaseUid,
        businessName: bundle.businessName,
        businessPhone: bundle.phone,
        businessAddress: bundle.address,
      );
    } catch (e) {
      errors.add('business profile upload: $e');
    }
  }

  /// Merges prefs for [firebaseUid] and guest workspace (pre-login edits).
  Future<BusinessProfile> _resolveLocalProfilesForUid(String firebaseUid) async {
    Future<BusinessProfile?> readProfile(String ws) =>
        _businessProfileRepository.getProfile(ws);

    final uidProfile = await readProfile(firebaseUid);
    final guestId = SessionBootstrap.tryReadGuestWorkspaceId();
    final guestProfile = (guestId != null &&
            guestId.isNotEmpty &&
            guestId != firebaseUid)
        ? await readProfile(guestId)
        : null;

    String pickPrimary(String? uidVal, String? guestVal) {
      final u = uidVal?.trim();
      if (u != null && u.isNotEmpty) return u;
      return guestVal?.trim() ?? '';
    }

    String? pickSecondary(String? uidVal, String? guestVal) {
      final u = uidVal?.trim();
      if (u != null && u.isNotEmpty) return u;
      final g = guestVal?.trim();
      if (g != null && g.isNotEmpty) return g;
      return null;
    }

    return BusinessProfile(
      workspaceId: firebaseUid,
      businessName:
          pickPrimary(uidProfile?.businessName, guestProfile?.businessName),
      phone:
          pickSecondary(uidProfile?.phone, guestProfile?.phone),
      address:
          pickSecondary(uidProfile?.address, guestProfile?.address),
      logoLocalPath:
          uidProfile?.logoLocalPath ?? guestProfile?.logoLocalPath,
    );
  }

  Future<void> _downloadBusinessProfileToPrefs(String firebaseUid) async {
    try {
      final cloud = await _businessProfileRemote.fetchBusinessText(firebaseUid);
      if (cloud == null) return;

      final existing =
          await _businessProfileRepository.getProfile(firebaseUid) ??
              BusinessProfile(
                workspaceId: firebaseUid,
                businessName: '',
                phone: null,
                address: null,
                logoLocalPath: null,
              );

      String mergeBusinessName(String remote, String local) {
        final r = remote.trim();
        if (r.isNotEmpty) return r;
        return local.trim();
      }

      String? mergeOptional(String? remote, String? local) {
        final r = remote?.trim();
        if (r != null && r.isNotEmpty) return r;
        final l = local?.trim();
        if (l != null && l.isNotEmpty) return l;
        return null;
      }

      final merged = BusinessProfile(
        workspaceId: firebaseUid,
        businessName: mergeBusinessName(
          cloud.businessName,
          existing.businessName,
        ),
        phone: mergeOptional(cloud.businessPhone, existing.phone),
        address: mergeOptional(cloud.businessAddress, existing.address),
        logoLocalPath: existing.logoLocalPath,
      );
      await _businessProfileRepository.saveProfile(merged);
    } catch (_) {}
  }

  Future<void> _performDownloadData(String firebaseUid) async {
    try {
      final clientEntities =
          await _clientsRemote.listClients(userId: firebaseUid);
      for (final c in clientEntities) {
        try {
          final local = ClientMappers.toLocal(
            _clientDownloaded(c, firebaseUid),
            syncStatusOverride: SyncStatus.synced,
          );
          await _clientsLocal.upsertClient(local);
        } catch (_) {
          // skip bad row
        }
      }

      final orderEntities =
          await _ordersRemote.listOrders(userId: firebaseUid);
      for (final o in orderEntities) {
        try {
          final local = OrderMappers.toLocal(
            _orderDownloaded(o, firebaseUid),
            syncStatusOverride: SyncStatus.synced,
          );
          await _ordersLocal.upsertOrder(local);
        } catch (_) {}
      }

      for (final o in orderEntities) {
        try {
          final payments =
              await _paymentsRemote.listPaymentsForOrder(orderId: o.id);
          for (final p in payments) {
            try {
              final local = PaymentMappers.toLocal(
                _paymentDownloaded(p, firebaseUid, o.id),
                syncStatusOverride: SyncStatus.synced,
              );
              await _paymentsLocal.upsertPayment(local);
            } catch (_) {}
          }
        } catch (_) {}
      }

      await _downloadBusinessProfileToPrefs(firebaseUid);
    } catch (_) {
      // e.g. network / permission — local DB unchanged for this sweep
    }
  }

  ClientEntity _clientDownloaded(ClientEntity remote, String uid) {
    return ClientEntity(
      id: remote.id,
      workspaceId: uid,
      name: remote.name,
      phone: remote.phone,
      notes: remote.notes,
      isDeleted: remote.isDeleted,
      createdAt: remote.createdAt,
      updatedAt: remote.updatedAt,
      syncStatus: SyncStatus.synced.code,
      remoteId: remote.remoteId ?? remote.id,
    );
  }

  OrderEntity _orderDownloaded(OrderEntity remote, String uid) {
    return OrderEntity(
      id: remote.id,
      workspaceId: uid,
      clientId: remote.clientId,
      description: remote.description,
      totalAmount: remote.totalAmount,
      totalPaid: remote.totalPaid,
      notes: remote.notes,
      isDeleted: remote.isDeleted,
      createdAt: remote.createdAt,
      updatedAt: remote.updatedAt,
      syncStatus: SyncStatus.synced.code,
      remoteId: remote.remoteId ?? remote.id,
    );
  }

  PaymentEntity _paymentDownloaded(
    PaymentEntity remote,
    String workspaceUid,
    String orderId,
  ) {
    return PaymentEntity(
      id: remote.id,
      workspaceId: workspaceUid,
      orderId: orderId,
      amount: remote.amount,
      isDeleted: remote.isDeleted,
      createdAt: remote.createdAt,
      updatedAt: remote.updatedAt,
      syncStatus: SyncStatus.synced.code,
      remoteId: remote.remoteId ?? remote.id,
    );
  }

  Future<void> _forPartitions({
    required String primary,
    required String uid,
    required Future<void> Function(String workspacePartition) runner,
  }) async {
    await runner(primary);
    if (primary != uid) await runner(uid);
  }

  bool _tryAcquireLock() {
    if (_busy) return false;
    _busy = true;
    return true;
  }

  void _releaseLock() {
    _busy = false;
  }

  ClientEntity _clientForRemote(ClientEntity e, String uid) {
    return ClientEntity(
      id: e.id,
      workspaceId: uid,
      name: e.name,
      phone: e.phone,
      notes: e.notes,
      isDeleted: false,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      syncStatus: 0,
      remoteId: e.remoteId ?? e.id,
    );
  }

  OrderEntity _orderForRemote(OrderEntity e, String uid) {
    return OrderEntity(
      id: e.id,
      workspaceId: uid,
      clientId: e.clientId,
      description: e.description,
      totalAmount: e.totalAmount,
      totalPaid: e.totalPaid,
      notes: e.notes,
      isDeleted: false,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      syncStatus: 0,
      remoteId: e.remoteId ?? e.id,
    );
  }

  PaymentEntity _paymentForRemote(PaymentEntity e, String uid) {
    return PaymentEntity(
      id: e.id,
      workspaceId: uid,
      orderId: e.orderId,
      amount: e.amount,
      isDeleted: false,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      syncStatus: 0,
      remoteId: e.remoteId ?? e.id,
    );
  }

  Future<void> _clientUpsertsForWorkspace(
    String workspacePartition,
    String firebaseUid,
    List<String> errors,
  ) async {
    final pending = await _clientsLocal.listPendingSync(
      workspaceId: workspacePartition,
    );
    for (final row in pending) {
      if (row.isDeleted) continue;
      try {
        final entity = _clientForRemote(
          ClientMappers.toEntity(row),
          firebaseUid,
        );
        await _clientsRemote.upsertClient(entity);
        await _clientsLocal.markSyncedAndRemapWorkspace(
          workspaceId: workspacePartition,
          id: row.id,
          newWorkspaceId: firebaseUid,
        );
      } catch (e) {
        errors.add('client upsert ${row.id}: $e');
      }
    }
  }

  Future<void> _orderUpsertsForWorkspace(
    String workspacePartition,
    String firebaseUid,
    List<String> errors,
  ) async {
    final pending = await _ordersLocal.listPendingSync(
      workspaceId: workspacePartition,
    );
    for (final row in pending) {
      if (row.isDeleted) continue;
      try {
        final entity = _orderForRemote(
          OrderMappers.toEntity(row),
          firebaseUid,
        );
        await _ordersRemote.upsertOrder(entity);
        await _ordersLocal.markSyncedAndRemapWorkspace(
          workspaceId: workspacePartition,
          id: row.id,
          newWorkspaceId: firebaseUid,
        );
      } catch (e) {
        errors.add('order upsert ${row.id}: $e');
      }
    }
  }

  Future<void> _paymentsForWorkspace(
    String workspacePartition,
    String firebaseUid,
    List<String> errors,
  ) async {
    final pending = await _paymentsLocal.listPendingSync(
      workspaceId: workspacePartition,
    );
    for (final row in pending) {
      try {
        if (row.isDeleted) {
          await _paymentsRemote.softDeletePayment(
            orderId: row.orderId,
            id: row.id,
          );
          await _paymentsLocal.deletePhysicalRow(
            workspaceId: workspacePartition,
            id: row.id,
          );
        } else {
          final entity = _paymentForRemote(
            PaymentMappers.toEntity(row),
            firebaseUid,
          );
          await _paymentsRemote.upsertPayment(entity);
          await _paymentsLocal.markSyncedAndRemapWorkspace(
            workspaceId: workspacePartition,
            id: row.id,
            newWorkspaceId: firebaseUid,
          );
        }
      } catch (e) {
        errors.add('payment ${row.id}: $e');
      }
    }
  }

  Future<void> _orderDeletesForWorkspace(
    String workspacePartition,
    String firebaseUid,
    List<String> errors,
  ) async {
    final pending = await _ordersLocal.listPendingSync(
      workspaceId: workspacePartition,
    );
    for (final row in pending) {
      if (!row.isDeleted) continue;
      try {
        await _ordersRemote.softDeleteOrder(
          userId: firebaseUid,
          id: row.id,
        );
        await _ordersLocal.deletePhysicalRow(
          workspaceId: workspacePartition,
          id: row.id,
        );
      } catch (e) {
        errors.add('order delete ${row.id}: $e');
      }
    }
  }

  Future<void> _clientDeletesForWorkspace(
    String workspacePartition,
    List<String> errors,
  ) async {
    final pending = await _clientsLocal.listPendingSync(
      workspaceId: workspacePartition,
    );
    for (final row in pending) {
      if (!row.isDeleted) continue;
      try {
        await _clientsRemote.deleteClientDocument(id: row.id);
        await _clientsLocal.deletePhysicalRow(
          workspaceId: workspacePartition,
          id: row.id,
        );
      } catch (e) {
        errors.add('client delete ${row.id}: $e');
      }
    }
  }
}
