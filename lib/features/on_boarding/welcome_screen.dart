import 'package:flutter/material.dart';
import 'package:in_your_hand/core/utils/screen_util.dart';
import 'package:in_your_hand/core/widgets/custom_button.dart';
import 'package:in_your_hand/features/authenticate/presentation/pages/sign_in.dart';
import '../../core/cache/cache_helper.dart';
import '../../core/utils/app_colors.dart';
import '../../l10n/app_localizations.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Center(
            child: Image.asset(
              "assets/icons/welcome.jpg",
              height: 300.h(context),
              width: 300.w(context),
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 40.h(context)),
          Text(
            l10n!.inYourHand,
            style: TextStyle(
              fontSize: 26.sp(context),
              fontWeight: FontWeight.bold,
              // color: Colors.white,
            ),
          ),
          Text(
            l10n.welcomeMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 14.0.sp(context)),
          ),
          SizedBox(height: 40.h(context)),
          CustomButton(
            onTap: () async{
              await CacheHelper.set(key: CacheKeys.isOnBoardingSeen, value: true);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) =>  SignIn()),
              );
            },
            title: l10n.letsStart,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
