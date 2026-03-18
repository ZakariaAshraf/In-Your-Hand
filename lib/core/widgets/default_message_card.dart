import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../utils/app_colors.dart';

class DefaultMessageCard extends StatelessWidget {
  final String sign;
  final String title;
  final String? subTitle;
  const DefaultMessageCard(
      {super.key,
      required this.sign,
      required this.title,
       this.subTitle});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: (35),
            backgroundColor: AppColors.whitePrimary.withOpacity(0.3),
            child: CircleAvatar(
              backgroundColor: Colors.grey.withOpacity(0.3),
              radius: (30),
              child: Text(
                sign,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: AppColors.primary, fontSize:  26),
              ).animate()
                  .fade(duration: 500.ms)
                  .scale(delay: 500.ms),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                     ),
                ).animate()
                .fade()
                .scale(),
                const SizedBox(
                  height: 10,
                ),
                if(subTitle !=null )
                Text(
                  subTitle!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontSize:20,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primary),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
