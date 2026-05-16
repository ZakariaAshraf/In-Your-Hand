import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:in_your_hand/core/utils/app_colors.dart';
import 'package:in_your_hand/core/utils/screen_util.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final void Function() ?onTap;
  final Color? color;
  final double? width;
  final double? height;
  final TextStyle? textStyle;
  final double? circularRadius;
  final bool isInvert;
  /// When true, tap is ignored and a small progress indicator is shown instead of [title].
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.title,
    required this.onTap,
    this.color,
    this.isInvert = true,
    this.width,
    this.height,
    this.circularRadius,
    this.textStyle,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {

    var theme = Theme.of(context);
    final bool isDisabled = onTap == null || isLoading;
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height:height ?? 60.h(context),
        width: width ??250.w(context),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(circularRadius ??10),
          // color: color ?? AppColors.primary,
          color: isDisabled ? Colors.grey : (color ?? AppColors.primary),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isInvert ? Colors.white : Colors.black,
                  ),
                )
              : Text(
                  title,
                  style: isInvert
                      ? textStyle ??
                          theme.textTheme.titleLarge!.copyWith(color: Colors.white)
                      : textStyle ??
                          theme.textTheme.titleLarge!.copyWith(color: Colors.black),
                ),
        ),
      ),
    ).animate()
        .animate().fade().slideX(duration: 300.ms,);
  }
}
