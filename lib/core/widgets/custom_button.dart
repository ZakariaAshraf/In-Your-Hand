import 'package:flutter/material.dart';
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

  const CustomButton({
    super.key,
    required this.title,
    required this.onTap,
    this.color,
    this.isInvert = true, this.width, this.height, this.circularRadius, this.textStyle,
  });

  @override
  Widget build(BuildContext context) {

    var theme = Theme.of(context);
    bool isDisabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
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
          child: Text(
            title,
            style: isInvert
                ?textStyle ?? theme.textTheme.titleLarge!.copyWith(color: Colors.white)
                :textStyle ??  theme.textTheme.titleLarge!.copyWith(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
