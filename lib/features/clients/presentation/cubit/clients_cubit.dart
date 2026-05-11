import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:in_your_hand/core/session/session_cubit.dart';
import 'package:in_your_hand/features/clients/data/clients_model.dart';
import 'package:in_your_hand/features/clients/data/services/picked_file_bytes.dart';
import 'package:in_your_hand/features/clients/domain/usecases/import_clients_from_file_use_case.dart';
import 'package:in_your_hand/features/clients/presentation/models/client_import_outcome.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/client_entity.dart';
import '../../domain/repositories/clients_repository.dart';

part 'clients_state.dart';

class ClientsCubit extends Cubit<ClientsState> {
  ClientsCubit({
    required ClientsRepository repository,
    required SessionCubit sessionCubit,
  })  : _repository = repository,
        _sessionCubit = sessionCubit,
        super(ClientsInitial()) {
    _sessionSub = _sessionCubit.stream.listen((state) {
      if (state is SessionLoaded) {
        _workspaceId = state.context.workspaceId;
        getClients();
      }
    });
    final existing = _sessionCubit.contextOrNull;
    if (existing != null) {
      _workspaceId = existing.workspaceId;
      getClients();
    }
  }

  final ClientsRepository _repository;
  final SessionCubit _sessionCubit;
  StreamSubscription? _sessionSub;
  String? _workspaceId;
  final ImportClientsFromFileUseCase _importClientsUseCase =
      const ImportClientsFromFileUseCase();

  Future<void> addClient(ClientModel client) async {
    emit(ClientsLoading());
    try {
      final wid = _workspaceId;
      if (wid == null) throw Exception('Session not ready');
      final id = (client.id == null || client.id!.isEmpty)
          ? const Uuid().v4()
          : client.id!;
      final now = DateTime.now();
      final entity = ClientEntity(
        id: id,
        workspaceId: wid,
        name: client.name,
        phone: client.phone,
        notes: client.notes,
        isDeleted: client.isDeleted,
        createdAt: client.createdAt,
        updatedAt: now,
        syncStatus: 1,
        remoteId: null,
      );
      await _repository.upsertClient(entity);
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
  /// After the SQLite file is deleted and recreated; same [workspaceId], empty tables.
  Future<void> refreshAfterLocalDatabaseReset() => getClients();

  /// Picks `.csv` / `.xlsx`, parses columns A/B/C (name / phone / notes), upserts locally.
  Future<ClientImportOutcome> pickAndImportClients() async {
    emit(ClientsLoading());
    try {
      final wid = _workspaceId;
      if (wid == null) {
        await getClients();
        return ClientImportOutcome.failure('Session not ready');
      }

      FilePickerResult? pickResult;
      try {
        pickResult = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: const ['csv', 'xlsx'],
          allowMultiple: false,
          withReadStream: false,
        );
      } catch (e) {
        await getClients();
        return ClientImportOutcome.failure(
          'Could not open file picker: $e',
        );
      }

      if (pickResult == null || pickResult.files.isEmpty) {
        await getClients();
        return ClientImportOutcome.cancelled();
      }

      final file = pickResult.files.single;
      List<int>? bytes;
      try {
        bytes = await readPickedSpreadsheetBytes(
          inlinedBytes: file.bytes,
          path: file.path,
        );
      } catch (e) {
        await getClients();
        return ClientImportOutcome.failure('Could not read file: $e');
      }

      if (bytes == null || bytes.isEmpty) {
        await getClients();
        return ClientImportOutcome.failure(
          'File was empty or could not be loaded (grant storage permission or try smaller file).',
        );
      }

      final ext =
          file.extension ?? _extensionFrom(file.name)?.replaceAll('.', '') ?? '';
      if (ext.isEmpty) {
        await getClients();
        return ClientImportOutcome.failure(
          'Pick a file with .csv or .xlsx extension.',
        );
      }

      late final int imported;
      try {
        imported = await _importClientsUseCase.execute(
          workspaceId: wid,
          repository: _repository,
          bytes: bytes,
          fileExtension: ext,
        );
      } on FormatException catch (e) {
        await getClients();
        return ClientImportOutcome.failure(e.message);
      } catch (e) {
        await getClients();
        return ClientImportOutcome.failure('$e');
      }

      await getClients();
      return ClientImportOutcome.success(imported);
    } catch (e) {
      try {
        await getClients();
      } catch (_) {}
      return ClientImportOutcome.failure('$e');
    }
  }

  static String? _extensionFrom(String name) {
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot >= name.length - 1) return null;
    return name.substring(dot + 1);
  }

  Future<void> getClients() async {
    emit(ClientsLoading());
    try {
      final wid = _workspaceId;
      if (wid == null) throw Exception('Session not ready');
      final entities = await _repository.listClients(workspaceId: wid);
      final clients = entities
          .map(
            (e) => ClientModel(
              id: e.id,
              userId: e.workspaceId,
              name: e.name,
              phone: e.phone,
              notes: e.notes,
              createdAt: e.createdAt,
              isDeleted: e.isDeleted,
            ),
          )
          .toList(growable: false);

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
      final wid = _workspaceId;
      if (wid == null) throw Exception('Session not ready');
      final id = (updatedClient.id == null || updatedClient.id!.isEmpty)
          ? oldClient.id ?? const Uuid().v4()
          : updatedClient.id!;
      final now = DateTime.now();
      final entity = ClientEntity(
        id: id,
        workspaceId: wid,
        name: updatedClient.name,
        phone: updatedClient.phone,
        notes: updatedClient.notes,
        isDeleted: updatedClient.isDeleted,
        createdAt: updatedClient.createdAt,
        updatedAt: now,
        syncStatus: 1,
        remoteId: null,
      );
      await _repository.upsertClient(entity);
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
      final wid = _workspaceId;
      if (wid == null) throw Exception('Session not ready');
      final id = client.id;
      if (id == null || id.isEmpty) throw Exception('Missing client id');
      await _repository.softDeleteClient(workspaceId: wid, id: id);
      await getClients();
    } catch (e) {
      emit(ClientsError(errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sessionSub?.cancel();
    return super.close();
  }
}
