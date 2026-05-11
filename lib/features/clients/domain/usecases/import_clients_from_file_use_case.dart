import 'package:uuid/uuid.dart';

import '../entities/client_entity.dart';
import '../import/client_import_row.dart';
import '../repositories/clients_repository.dart';
import '../../data/services/clients_spreadsheet_parser.dart';

class ImportClientsFromFileUseCase {
  const ImportClientsFromFileUseCase({
    ClientsSpreadsheetParser? parser,
  }) : _parser = parser ?? const ClientsSpreadsheetParser();

  final ClientsSpreadsheetParser _parser;

  Future<int> execute({
    required String workspaceId,
    required ClientsRepository repository,
    required List<int> bytes,
    required String fileExtension,
  }) async {
    final ext =
        fileExtension.trim().replaceAll('.', '').toLowerCase();
    final List<ClientImportRow> rows;
    try {
      rows = switch (ext) {
        'csv' => _parser.parseCsv(bytes),
        'xlsx' => _parser.parseExcel(bytes),
        _ => throw FormatException(
            'Unsupported file type ".$ext". Use .csv or .xlsx.',
          ),
      };
    } on UnsupportedError catch (e) {
      throw FormatException('$e');
    } on FormatException {
      rethrow;
    }

    final now = DateTime.now();
    var count = 0;
    final uuid = const Uuid();

    try {
      for (final row in rows) {
        final name = row.name.trim();
        if (name.isEmpty) continue;

        final entity = ClientEntity(
          id: uuid.v4(),
          workspaceId: workspaceId,
          name: name,
          phone: _trimOrNull(row.phone),
          notes: _trimOrNull(row.notes),
          createdAt: now,
          updatedAt: now,
          syncStatus: 1,
          remoteId: null,
        );
        await repository.upsertClient(entity);
        count++;
      }
      return count;
    } catch (e, st) {
      Error.throwWithStackTrace(
        StateError('Saving imported clients failed: $e'),
        st,
      );
    }
  }

  static String? _trimOrNull(String? s) {
    if (s == null) return null;
    final t = s.trim();
    return t.isEmpty ? null : t;
  }
}
