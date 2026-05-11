import 'dart:typed_data';

/// Web: only inlined bytes from [file_picker] are available.
Future<Uint8List?> readPickedSpreadsheetBytes({
  required Uint8List? inlinedBytes,
  required String? path,
}) async {
  if (inlinedBytes == null || inlinedBytes.isEmpty) return null;
  return inlinedBytes;
}
