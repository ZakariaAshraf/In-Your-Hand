import 'dart:typed_data';

import 'picked_file_bytes_io.dart'
    if (dart.library.html) 'picked_file_bytes_stub.dart' as impl;

Future<Uint8List?> readPickedSpreadsheetBytes({
  required Uint8List? inlinedBytes,
  required String? path,
}) =>
    impl.readPickedSpreadsheetBytes(
      inlinedBytes: inlinedBytes,
      path: path,
    );
