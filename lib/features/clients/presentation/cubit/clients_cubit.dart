import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:in_your_hand/features/clients/data/clients_model.dart';
import 'package:meta/meta.dart';

part 'clients_state.dart';

class ClientsCubit extends Cubit<ClientsState> {
  ClientsCubit() : super(ClientsInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get userId => _auth.currentUser!.uid;

  Future<void> addClient(ClientModel client) async {
    emit(ClientsLoading());
    try {
      await _firestore.collection('clients').add(
        client.toFirestore(),
      );
      await getClients();
      // emit(AddingClientSuccess(successMessage: "Client saved successfully"));
    } catch (e) {
      emit(ClientsError(errorMessage: e.toString()));
    }
  }
  ClientModel? getClientById(String clientId) {
    if (state is ClientsSuccess) {
      final clients = (state as ClientsSuccess).clients;
      try {
        return clients.firstWhere((c) => c.id == clientId);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
  Map<String, ClientModel> get clientsMap {
    if (state is ClientsSuccess) {
      return {
        for (var c in (state as ClientsSuccess).clients) ?c.id: c
      };
    }
    return {};
  }
  Future<void> getClients() async {
    emit(ClientsLoading());
    try {
      final snapshot = await _firestore
          .collection('clients')
          .where('userId', isEqualTo: userId)
          // .orderBy('createdAt', descending: true)
          .get();

      final clients = snapshot.docs
          .map((doc) => ClientModel.fromFirestore(doc))
          .toList();

      emit(ClientsSuccess(clients: clients));
    } catch (e) {
      emit(ClientsError(errorMessage: e.toString()));
    }
  }

  Future<void> updateClient(
      ClientModel oldClient,
      ClientModel updatedClient,
      ) async {
    emit(ClientsLoading());
    try {
      await _firestore
          .collection('clients')
          .doc(oldClient.id)
          .update(updatedClient.toFirestore());
      await getClients();

      // emit(AddingClientSuccess(successMessage: "Client updated successfully"));
    } catch (e) {
      emit(ClientsError(errorMessage: e.toString()));
    }
  }

  // Future<void> deleteClient(ClientModel client) async {
  //   emit(ClientsLoading());
  //   try {
  //     await _firestore
  //         .collection('clients')
  //         .doc(client.id)
  //         .delete();
  //     await getClients();
  //   } catch (e) {
  //     emit(ClientsError(errorMessage: e.toString()));
  //   }
  // }
  Future<void> deleteClient(ClientModel client) async {
    emit(ClientsLoading());
    try {
      await _firestore
          .collection('clients')
          .doc(client.id)
          .update({
        'isDeleted': true,
      });

      await getClients();
    } catch (e) {
      emit(ClientsError(errorMessage: e.toString()));
    }
  }

}
