import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_your_hand/core/utils/screen_util.dart';
import '../../../../core/generated/assets_helper.dart';
import '../../../../core/generated/extentions.dart';
import '../../../../core/locale/widgets/language_toggle_button.dart';
import '../../../../core/themes/widgets/theme_toggle_button.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../main.dart';
import '../../../authenticate/presentation/manager/auth_cubit.dart';
import '../../../authenticate/presentation/pages/sign_in.dart';
import '../../../help_support/help_support_screen.dart';
import '../components/settings_button.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';

class SettingScreen extends StatefulWidget {
  final String name;
  final String phone;
  final String? photoUrl;

  const SettingScreen({
    super.key,
    required this.name,
    required this.phone,
    this.photoUrl,
  });

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    String imagePath = getCharacterAssetPath(widget.photoUrl ?? "");
    final l10n = AppLocalizations.of(context);
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const SignIn()),
                (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n!.settings, style: theme.titleLarge),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // padding: const EdgeInsets.symmetric(horizontal: 15),
              children: [
                /// photo and information section
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: Color(0xffe8d4d4),
                            radius: 60,
                            child: ClipOval(
                              child: Image.asset(
                                imagePath,
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                              ),
                            ),
                          ),
                          // Positioned(
                          //   bottom: 0,
                          //   right: 0,
                          //   child: InkWell(
                          //     onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChangeCharacterScreen(),)),
                          //
                          //     child: Container(
                          //       // height: 40,
                          //       // width: 64.w(context),
                          //       padding: EdgeInsets.all(7),
                          //       decoration: BoxDecoration(
                          //         border: BoxBorder.all(color: Colors.white),
                          //         shape: BoxShape.circle,
                          //         color: Colors.blueAccent,
                          //       ),
                          //       child: Row(
                          //         children: [
                          //           Icon(
                          //             Icons.edit,
                          //             color: Colors.white,
                          //             size: 18,
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(widget.name, style: theme.titleLarge),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.map_pin,
                            color: Colors.red,
                            size: 20,
                          ),
                          Text(
                            // l10n.cairoEgypt,
                            l10n.egypt,
                            style: theme.bodyMedium!.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      CustomButton(
                        title: l10n.editProfile,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        },
                        isInvert: false,
                        color: Colors.white,
                        width: 180.w(context),
                        textStyle: theme.titleMedium!.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        circularRadius: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.preferences,
                  style: theme.titleMedium!.copyWith(color: Colors.grey),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ThemeToggleButton(),
                      LanguageToggleButton(),
                    ],
                  ),
                ),
                Text(
                  l10n.supportAndAccount,
                  style: theme.titleMedium!.copyWith(color: Colors.grey),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SettingsButton(
                        title: l10n.recommendFeature,
                        function: () async {
                          await launchUrls("https://forms.gle/G3V7PwjhPdm6MBtU6");
                        },
                        iconData: Icons.lightbulb_outlined,
                        iconColor: Colors.yellow,
                      ),
                      SettingsButton(
                        title: l10n.helpAndSupport,
                        function: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HelpSupportScreen(),
                            ),
                          );
                          },
                        iconData: Icons.question_mark_rounded,
                      ),
                      SettingsButton(
                        title: l10n.changePassword,
                        function: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ChangePasswordScreen(),
                            ),
                          );
                        },
                        iconData: Icons.lock_open_outlined,
                      ),
                      SettingsButton(
                        title: l10n.logout,
                        function: () async {
                          try {
                            context.read<AuthCubit>().signOut();
                            if (context.mounted) {
                              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => const SignIn()),
                                    (route) => false,
                              );
                            }
                          } catch (e) {
                            if (kDebugMode) {
                              print(e.toString());
                            }
                          }
                        },
                        iconData: Icons.logout,
                        iconColor: Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
