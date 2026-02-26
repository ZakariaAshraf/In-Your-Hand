import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:in_your_hand/features/dashboard/data/dashboard_model.dart';
import 'package:meta/meta.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(DashboardInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get userId => _auth.currentUser!.uid;
  Future<void> loadDashboard(String userId) async {
    emit(DashboardLoading());

    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();

      double totalAmount = 0;
      double totalPaid = 0;
      int totalOrders = snapshot.docs.length;

      final clientsWithDebtSet = <String>{};
      final clientsIds = <String>{};

      for (var doc in snapshot.docs) {
        final data = doc.data();

        final amount = (data['totalAmount'] ?? 0) as num;
        final paid = (data['totalPaid'] ?? 0) as num;
        final clientId = data['clientId'];

        totalAmount += amount.toDouble();
        totalPaid += paid.toDouble();

        if (paid < amount) {
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
}
