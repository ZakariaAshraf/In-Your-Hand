import 'package:flutter/widgets.dart';

import 'business_logo_display_stub.dart'
    if (dart.library.io) 'business_logo_display_io.dart' as logo_display_io;

Widget buildBusinessLogoDisplay({
  required String? logoLocalPath,
  required double size,
  required Widget fallback,
}) {
  return logo_display_io.buildBusinessLogoDisplay(
    logoLocalPath: logoLocalPath,
    size: size,
    fallback: fallback,
  );
}
