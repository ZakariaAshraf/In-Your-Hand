import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_your_hand/core/utils/screen_util.dart';
import 'package:in_your_hand/features/authenticate/presentation/pages/sign_up.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../settings/presentation/Cubit/user_cubit.dart';
import '../../../settings/presentation/screens/change_password_screen.dart';
import '../manager/auth_cubit.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    var theme = Theme.of(context).textTheme;
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) async {
          if (state is AuthSuccess) {
            final userId = state.user.id;
            context.read<UserCubit>().listenToFirebaseStream(userId);
            Navigator.pushNamedAndRemoveUntil(
              context,
              "/main_screen",
              (route) => false,
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.loginFailed),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    children: [
                      // Text(
                      //   l10n.welcomeBack,
                      //   textAlign: TextAlign.center,
                      //   style: theme.titleLarge!.copyWith(
                      //     fontSize: 30.0.sp(context),
                      //     fontWeight: FontWeight.w600,
                      //   ),
                      // ),
                      // SizedBox(height: 10.h(context)),
                      Image(
                        height: 200.h(context),
                        width: 150.w(context),
                        image: AssetImage("assets/icons/icon_foreground.png"),
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 30),
                      Text(
                        l10n.welcome,
                        textAlign: TextAlign.center,
                        style: theme.titleLarge!.copyWith(
                          fontSize: 30.0.sp(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 5),
                      Text(
                        l10n.signInMessage,
                        textAlign: TextAlign.center,
                        style: theme.bodySmall!.copyWith(
                          fontSize: 18.0.sp(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 30),
                      CustomTextField(
                        controller: emailController,
                        hintText: l10n.email,
                      ),
                      const SizedBox(height: 30),
                      CustomTextField(
                        isPassword: true,
                        controller: passwordController,
                        hintText: l10n.password,
                      ),
                      InkWell(
                        onTap: () async {
                          try {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChangePasswordScreen(),
                              ),
                            );
                          } catch (e) {
                            if (kDebugMode) {
                              print(e.toString());
                            }
                          }
                        },
                        child: Container(
                          alignment: Alignment.topRight,
                          margin: const EdgeInsets.all(10),
                          child: Text(
                            l10n.forgetPassword,
                            style: theme.bodySmall!.copyWith(
                              fontSize: 14.sp(context),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      //sign in button
                      Center(
                        child: CustomButton(
                          title: l10n.login,
                          width: 300.w(context),
                          onTap: () {
                            context.read<AuthCubit>().signIn(
                              emailController.text,
                              passwordController.text,
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 50.h(context)),
                      // Center(
                      //   child: CustomButton(
                      //     width: 300.w(context),
                      //     isInvert: true,
                      //     title: l10n.continueAsGuest,
                      //     onTap: () {},
                      //   ),
                      // ),
                      SizedBox(height: 60.h(context)),

                      Divider(),
                      Row(
                        children: [
                          Text(
                            l10n.dontHaveAccount,
                            style: TextStyle(color: Colors.grey),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUp(),
                                ),
                                (route) => true,
                              );
                            },
                            child: Text(
                              l10n.create,
                              style: TextStyle(color: Color(0xff1F4C6B)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
