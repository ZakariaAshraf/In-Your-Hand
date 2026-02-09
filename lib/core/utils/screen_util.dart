import 'dart:math';

import 'package:flutter/cupertino.dart';
class AppConstants {
static const double totalFigmaWidth = 390;
static const double totalFigmaHeight = 844;
}
extension ContextExtensions on BuildContext {
  /// Returns the width of the screen.
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Returns the height of the screen.
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Returns the TextScaler from MediaQuery.
  /// This is used for accessibility-aware text scaling.
  TextScaler get textScaler => MediaQuery.of(this).textScaler;
}
extension ResponsiveNum on num {
  /// Internal helper to get the base text scale factor.
  /// It uses the smaller of the width/height scale factors to maintain aspect ratio,
  /// and clamps it to prevent text from becoming too small or too large.
  double _textScale(BuildContext context) {
    final double scaleWidth = context.screenWidth / AppConstants.totalFigmaWidth;
    final double scaleHeight = context.screenHeight / AppConstants.totalFigmaHeight;
    return min(scaleWidth, scaleHeight).clamp(0.8, 1.4);
  }

  /// SCALES HORIZONTALLY:
  /// Scales the number based on the screen *width*.
  /// Use this for `width`, horizontal `padding`, horizontal `margin`, etc.
  double w(BuildContext context) {
    return (this / AppConstants.totalFigmaWidth) * context.screenWidth;
  }

  /// SCALES VERTICALLY:
  /// Use this for `height`, vertical `padding`, vertical `margin`, etc.
  double h(BuildContext context) {
    return (this / AppConstants.totalFigmaHeight) * context.screenHeight;
  }

  /// SCALES UNIFORMLY (like 'sp' or 'r'):
  /// Use this for `fontSize` if you want to *ignore* system font scaling.
  double sp(BuildContext context) {
    return this * _textScale(context);
  }

  /// SCALES UNIFORMLY (like 'sp' or 'r'):
  /// Use this for `padding`, `margin`, `borderRadius`, `iconSize`, etc.,
  /// that should scale uniformly with the screen.
  double r(BuildContext context) {
    return this * _textScale(context);
  }

  /// ACCESSIBILITY-AWARE FONT SCALING:
  /// Scales the number based on the uniform scale factor AND respects
  /// the user's system text size settings.
  ///
  /// **THIS IS THE RECOMMENDED METHOD FOR ALL FONT SIZES.**
  double ac(BuildContext context) {
    return context.textScaler.scale(this * _textScale(context));
  }
}