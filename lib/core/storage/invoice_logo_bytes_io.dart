import 'dart:io';
import 'dart:typed_data';

Future<Uint8List?> readLogoBytesForPdf(String? logoLocalPath) async {
  if (logoLocalPath == null || logoLocalPath.trim().isEmpty) return null;
  try {
    final f = File(logoLocalPath.trim());
    if (!await f.exists()) return null;
    return await f.readAsBytes();
  } catch (_) {
    return null;
  }
}
