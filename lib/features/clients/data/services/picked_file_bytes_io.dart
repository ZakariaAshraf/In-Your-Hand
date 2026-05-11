import 'dart:io';
import 'dart:typed_data';

/// Reads spreadsheet bytes from a picker result ([inlinedBytes] or [path]).
Future<Uint8List?> readPickedSpreadsheetBytes({
  required Uint8List? inlinedBytes,
  required String? path,
}) async {
  if (inlinedBytes != null && inlinedBytes.isNotEmpty) {
    return inlinedBytes;
  }
  if (path == null || path.isEmpty) return null;
  final file = File(path);
  if (!await file.exists()) return null;
  return file.readAsBytes();
}
