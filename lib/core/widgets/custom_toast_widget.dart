import 'package:flutter/material.dart';
import 'package:in_your_hand/core/utils/screen_util.dart';
import 'package:toastification/toastification.dart';

class CustomToastWidget {
  static void show({
    required BuildContext context,
    required String title,
    required String iconPath,
    Color? iconBackgroundColor,
    Color? backgroundColor,
    Duration? autoCloseDuration,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.simple,
      title: Row(
        children: [
          Container(
            width: 24.w(context),
            height: 24.h(context),
            decoration: BoxDecoration(
              color: iconBackgroundColor ?? Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: iconPath.toLowerCase().endsWith('.svg')
                  ? Image.asset(
                      iconPath,
                      width: 16.w(context),
                      height: 16.h(context),
                    )
                  : Image.asset(
                      iconPath,
                      width: 30.w(context),
                      height: 30.h(context),
                    ),
            ),
          ),
          SizedBox(width: 10.w(context)),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15.sp(context),
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
      alignment: Alignment.bottomCenter,
      autoCloseDuration: autoCloseDuration ?? const Duration(seconds: 3),
      backgroundColor: backgroundColor ?? (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFFFEFE8)),
      margin: EdgeInsets.only(
        top: 650.h(context),
        left: 60.w(context),
        right: 60.w(context),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 10.h(context)),
      borderRadius: BorderRadiusGeometry.all(Radius.circular(25.r(context))),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10.r(context),
          offset: const Offset(0, 2),
        ),
      ],
      closeButton: const ToastCloseButton(showType: CloseButtonShowType.none),
    );
  }
}
