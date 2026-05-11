import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';

import '../../domain/import/client_import_row.dart';

typedef _CellStrings = List<String>;

/// Parses column layout: **A** = name, **B** = phone, **C** = notes / starting balance.
class ClientsSpreadsheetParser {
  const ClientsSpreadsheetParser();

  List<ClientImportRow> parseCsv(List<int> bytes) {
    final text = utf8.decode(bytes, allowMalformed: true);
    final stripped = text.startsWith('\ufeff') ? text.substring(1) : text;
    const converter = CsvToListConverter(shouldParseNumbers: false);
    final raw = converter.convert(stripped);
    return _consumeRawRows(raw);
  }

  List<ClientImportRow> parseExcel(List<int> bytes) {
    late final Excel workbook;
    try {
      workbook = Excel.decodeBytes(bytes);
    } on UnsupportedError {
      rethrow;
    } catch (e, st) {
      Error.throwWithStackTrace(
        FormatException('Not a valid .xlsx file: $e'),
        st,
      );
    }

    if (workbook.tables.isEmpty) return [];
    final sheet = workbook.tables.values.first;
    final raw = <List<dynamic>>[];
    for (final row in sheet.rows) {
      raw.add(row.map(_cellToPlainString).toList());
    }
    return _consumeRawRows(raw);
  }

  List<ClientImportRow> _consumeRawRows(List<List<dynamic>> raw) {
    final out = <ClientImportRow>[];
    var firstRow = true;
    var blankTail = 0;
    const maxBlankTailBeforeStop = 50;

    for (final dynamicRow in raw) {
      final cells = _normalizeRow(dynamicRow);
      if (!_hasAnyNonWhitespace(cells)) {
        blankTail++;
        if (blankTail >= maxBlankTailBeforeStop && out.isNotEmpty) {
          break;
        }
        continue;
      }
      blankTail = 0;

      if (firstRow && _isLikelyHeaderRow(cells)) {
        firstRow = false;
        continue;
      }
      firstRow = false;

      final parsed = _rowFromCells(cells);
      if (parsed != null) out.add(parsed);
    }
    return out;
  }

  _CellStrings _normalizeRow(List<dynamic> row) {
    final list = row.map(_dynamicToTrimmedString).toList();
    while (list.length < 3) {
      list.add('');
    }
    return list;
  }

  bool _hasAnyNonWhitespace(_CellStrings cells) {
    for (final s in cells) {
      if (s.trim().isNotEmpty) return true;
    }
    return false;
  }

  String _dynamicToTrimmedString(dynamic v) =>
      v == null ? '' : v.toString().trim();

  String _cellToPlainString(Data? cell) =>
      cell == null ? '' : _cellValueToPlain(cell.value);

  String _cellValueToPlain(CellValue? v) => v?.toString().trim() ?? '';

  bool _isLikelyHeaderRow(_CellStrings cells) {
    if (cells.isEmpty) return false;
    final a = cells[0].trim().toLowerCase();
    const headers = {
      'name',
      'full name',
      'client name',
      'customer',
      'client',
      'الاسم',
      'الاسم الكامل',
    };
    return headers.contains(a);
  }

  ClientImportRow? _rowFromCells(_CellStrings cells) {
    final name = cells[0].trim();
    if (name.isEmpty) return null;

    final phone = _nullableField(cells.length > 1 ? cells[1] : '');
    final notes = _nullableField(cells.length > 2 ? cells[2] : '');
    return ClientImportRow(name: name, phone: phone, notes: notes);
  }

  String? _nullableField(String s) {
    final t = s.trim();
    return t.isEmpty ? null : t;
  }
}
