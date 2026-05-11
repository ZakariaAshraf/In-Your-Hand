import 'dart:io';

import 'package:flutter/widgets.dart';

Widget buildBusinessLogoDisplay({
  required String? logoLocalPath,
  required double size,
  required Widget fallback,
}) {
  final path = logoLocalPath?.trim();
  if (path == null || path.isEmpty) {
    return SizedBox.square(dimension: size, child: fallback);
  }
  try {
    final file = File(path);
    if (file.existsSync()) {
      return SizedBox.square(
        dimension: size,
        child: Image.file(
          file,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (_, __, ___) => fallback,
        ),
      );
    }
  } catch (_) {}
  return SizedBox.square(dimension: size, child: fallback);
}
