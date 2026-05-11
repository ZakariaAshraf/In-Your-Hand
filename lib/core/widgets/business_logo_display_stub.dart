import 'package:flutter/widgets.dart';

Widget buildBusinessLogoDisplay({
  required String? logoLocalPath,
  required double size,
  required Widget fallback,
}) =>
    SizedBox.square(dimension: size, child: fallback);
