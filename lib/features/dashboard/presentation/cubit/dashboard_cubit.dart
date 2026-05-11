import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:in_your_hand/core/session/session_cubit.dart';
import 'package:in_your_hand/features/dashboard/data/dashboard_model.dart';
import 'package:meta/meta.dart';

import '../../../orders/domain/repositories/orders_repository.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required OrdersRepository ordersRepository,
    required SessionCubit sessionCubit,
  })  : _ordersRepository = ordersRepository,
        _sessionCubit = sessionCubit,
        super(DashboardInitial()) {
    _sessionSub = _sessionCubit.stream.listen((state) {
      if (state is SessionLoaded) {
        _workspaceId = state.context.workspaceId;
        loadDashboard();
      }
    });
    final existing = _sessionCubit.contextOrNull;
    if (existing != null) {
      _workspaceId = existing.workspaceId;
      loadDashboard();
    }
  }

  final OrdersRepository _ordersRepository;
  final SessionCubit _sessionCubit;
  StreamSubscription? _sessionSub;
  String? _workspaceId;

  Future<void> refreshAfterLocalDatabaseReset() => loadDashboard();

  Future<void> loadDashboard() async {
    emit(DashboardLoading());

    try {
      final wid = _workspaceId;
      if (wid == null) throw Exception('Session not ready');

      final orders = await _ordersRepository.listOrders(workspaceId: wid);

      double totalAmount = 0;
      double totalPaid = 0;
      int totalOrders = orders.length;

      final clientsWithDebtSet = <String>{};
      final clientsIds = <String>{};

      for (final o in orders) {
        totalAmount += o.totalAmount;
        totalPaid += o.totalPaid;

        if (o.totalPaid < o.totalAmount) {
          final clientId = o.clientId;
          clientsWithDebtSet.add(clientId);
          clientsIds.add(clientId);
        }
      }

      final dashboard = DashboardData(
        totalAmount: totalAmount,
        totalPaid: totalPaid,
        totalUnpaid: totalAmount - totalPaid,
        totalOrders: totalOrders,
        clientsWithDebt: clientsWithDebtSet.length, clientsIds: clientsIds.toList(),
      );

      emit(DashboardLoaded(dashboard: dashboard));
    } catch (e) {
      emit(DashboardError(errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sessionSub?.cancel();
    return super.close();
  }
}
