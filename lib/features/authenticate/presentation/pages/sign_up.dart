import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_your_hand/core/utils/screen_util.dart';
import 'package:in_your_hand/features/authenticate/presentation/pages/sign_in.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../manager/auth_cubit.dart';
import 'choose_your_character_screen.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController nationalityController = TextEditingController();

  bool areFieldsFilled() {
    return nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        phoneController.text.isNotEmpty;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    nationalityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    var theme = Theme.of(context).textTheme;
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                Image(
                  height: 200.h(context),
                  width: 150.w(context), image: AssetImage("assets/icons/icon_foreground.png",),fit: BoxFit.contain,
                ),
                Text(
                  l10n!.joinApplication,
                  textAlign: TextAlign.center,
                  style: theme.titleLarge!.copyWith(
                    fontSize: 30.0.sp(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // SizedBox(height: 10.h(context)),
                // Text(
                //   l10n.signUpDescription,
                //   textAlign: TextAlign.center,
                //   style: theme.bodySmall!.copyWith(
                //     fontSize: 18.0.sp(context),
                //     fontWeight: FontWeight.w600,
                //   ),
                // ),
                SizedBox(height: 20.h(context)),

                CustomTextField(
                  controller: nameController,
                  hintText: l10n.fullName,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: emailController,
                  hintText: l10n.email,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  isPassword: true,
                  controller: passwordController,
                  hintText: l10n.password,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: phoneController,
                  hintText: l10n.phoneNumber,
                ),
                const SizedBox(height: 30),

                Center(
                  child: CustomButton(
                    title: l10n.register,
                    onTap: () {
                      if (areFieldsFilled()) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChooseYourCharacterScreen(
                              email: emailController.text,
                              password: passwordController.text,
                              phoneNumber: phoneController.text,
                              name: nameController.text,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.pleaseFillAllFields,
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    l10n.orContinueWith,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.alreadyHaveAccount,
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignIn(),
                          ),
                          (route) => true,
                        );
                      },
                      child: Text(
                        l10n.login,
                        style: TextStyle(color: Color(0xff1F4C6B)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
