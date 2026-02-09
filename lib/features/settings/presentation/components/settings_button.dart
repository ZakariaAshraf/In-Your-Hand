
import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';

class SettingsButton extends StatelessWidget {
  final String title;
  final Color? iconColor;
  final Function function;
  final IconData iconData;
  const SettingsButton(
      {super.key,
      required this.title,
      required this.function,
      required this.iconData, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 0.5,
        child: ListTile(
          onTap: () => function(),
          leading: Icon(
            iconData,
            color: iconColor ??AppColors.blackSecondary,
          ),
          trailing: Icon(Icons.arrow_forward_ios,size: 8,),
          title: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium,
          ),
        ));
  }
}
