import 'package:flutter/material.dart';
import 'package:in_your_hand/core/utils/screen_util.dart';
import '../utils/app_colors.dart';

class AppTextTheme {
  static TextTheme lightTextTheme(BuildContext context) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 20.sp(context),
        fontWeight: FontWeight.normal,
        color: AppColors.blackSecondary,
      ),
      titleLarge: TextStyle(
        fontSize: 25.sp(context),
        fontWeight: FontWeight.bold,
        color: AppColors.blackSecondary,
      ),
      // Page titles
      bodyLarge: TextStyle(
        fontSize: 15.sp(context),
        color: AppColors.blackSecondary,
        fontWeight: FontWeight.w800,
      ),
      // Paragraph text
      titleMedium: TextStyle(
        fontSize: 16.sp(context),
        fontWeight: FontWeight.w500,
        color: AppColors.blackSecondary,
      ),
      // List titles
      titleSmall: TextStyle(
        fontSize: 12.sp(context),
        fontWeight: FontWeight.bold,
        color: AppColors.blackSecondary,
      ),
      bodySmall: TextStyle(
        fontSize: 10.sp(context),
        color: Colors.grey,
      ),
      bodyMedium: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18.sp(context),
        color: AppColors.blackSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: 14.sp(context),
        fontWeight: FontWeight.w500,
        color: AppColors.blackSecondary,
      ),
    );
  }

  static TextTheme darkTextTheme(BuildContext context) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 20.sp(context),
        fontWeight: FontWeight.bold,
        color: AppColors.whitePrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 25.sp(context),
        fontWeight: FontWeight.bold,
        color: AppColors.whitePrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 15.sp(context),
        color: AppColors.whitePrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 14.sp(context),
        fontWeight: FontWeight.w500,
        color: AppColors.whitePrimary,
      ),
      titleSmall: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12.sp(context),
        color: AppColors.whitePrimary,
      ),
      bodySmall: TextStyle(
        fontSize: 10.sp(context),
        color: Colors.grey,
      ),
      bodyMedium: TextStyle(
        fontSize: 18.sp(context),
        color: AppColors.whitePrimary,
        fontWeight: FontWeight.bold,
      ),
      labelLarge: TextStyle(
        fontSize: 14.sp(context),
        fontWeight: FontWeight.w500,
        color: AppColors.whitePrimary,
      ),
    );
  }
}