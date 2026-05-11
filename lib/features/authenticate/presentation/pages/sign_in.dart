import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_your_hand/core/utils/screen_util.dart';
import 'package:in_your_hand/features/authenticate/presentation/pages/complete_google_registration_screen.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../settings/presentation/screens/change_password_screen.dart';
import '../manager/auth_cubit.dart';
import '../../../../main_screen.dart';

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
          final route = ModalRoute.of(context);
          final isSignInRouteCurrent = route?.isCurrent ?? true;

          if (state is AuthSuccess) {
            if (!isSignInRouteCurrent) {
              return;
            }
            // Session + sync pipeline (AuthSyncCoordinator) run from SessionCubit.refresh.
            await context.read<SessionCubit>().refresh();
            if (!context.mounted) return;
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil<void>(
              MaterialPageRoute<void>(builder: (_) => const MainScreen()),
              (route) => false,
            );
          } else if (state is AuthNeedsOnboarding) {
            if (!isSignInRouteCurrent) {
              return;
            }
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => CompleteGoogleRegistrationScreen(
                  user: state.user,
                ),
              ),
            );
          } else if (state is AuthFailure) {
            if (!isSignInRouteCurrent) {
              return;
            }
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
          final route = ModalRoute.of(context);
          final isSignInRouteCurrent = route?.isCurrent ?? true;
          if (state is AuthLoading && isSignInRouteCurrent) {
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
                      SizedBox(height: 20.h(context)),
                      Center(
                        child: CustomButton(
                          color: Colors.transparent,
                          textStyle: theme.titleMedium!.copyWith(color: Colors.green),
                          width: 300.w(context),
                          isInvert: true,
                          title: l10n.continueAsGuest,
                          onTap: () async {
                            await context.read<SessionCubit>().ensureGuest();
                            if (!context.mounted) return;
                            Navigator.of(context, rootNavigator: true)
                                .pushAndRemoveUntil<void>(
                              MaterialPageRoute<void>(
                                builder: (_) => const MainScreen(),
                              ),
                                  (route) => false,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Premium paywall will own Google sign-in again (RevenueCat).
                      // Row(
                      //   children: [
                      //     const Expanded(child: Divider()),
                      //     Padding(
                      //       padding: const EdgeInsets.symmetric(horizontal: 12),
                      //       child: Text(
                      //         l10n.orContinueWith,
                      //         style: theme.bodySmall?.copyWith(
                      //           color: Colors.grey.shade600,
                      //           fontWeight: FontWeight.w500,
                      //         ),
                      //       ),
                      //     ),
                      //     const Expanded(child: Divider()),
                      //   ],
                      // ),
                      // SizedBox(height: 16.h(context)),
                      // Center(
                      //   child: SizedBox(
                      //     width: 300.w(context),
                      //     height: 52.h(context),
                      //     child: OutlinedButton(
                      //       style: OutlinedButton.styleFrom(
                      //         foregroundColor: const Color(0xFF3C4043),
                      //         backgroundColor: Colors.white,
                      //         side: const BorderSide(color: Color(0xFFDADCE0)),
                      //         shape: RoundedRectangleBorder(
                      //           borderRadius: BorderRadius.circular(10),
                      //         ),
                      //         elevation: 0,
                      //       ),
                      //       onPressed: () {
                      //         context.read<AuthCubit>().signInWithGoogle();
                      //       },
                      //       child: Row(
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         children: [
                      //           Image.asset(
                      //             "assets/icons/ic_google.png",
                      //             width: 24.w(context),
                      //             height: 24.h(context),
                      //           ),
                      //           SizedBox(width: 12.w(context)),
                      //           Text(
                      //             l10n.continueWithGoogle,
                      //             style: theme.titleMedium?.copyWith(
                      //               fontWeight: FontWeight.w600,
                      //               fontSize: 16.sp(context),
                      //               color: const Color(0xFF3C4043),
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: 40.h(context)),
                      // Divider(),
                      // Sign-up is gated behind Premium / paywall for new accounts.
                      // Row(
                      //   children: [
                      //     Text(
                      //       l10n.dontHaveAccount,
                      //       style: TextStyle(color: Colors.grey),
                      //     ),
                      //     TextButton(
                      //       onPressed: () {
                      //         Navigator.pushAndRemoveUntil(
                      //           context,
                      //           MaterialPageRoute(
                      //             builder: (context) => const SignUp(),
                      //           ),
                      //           (route) => true,
                      //         );
                      //       },
                      //       child: Text(
                      //         l10n.create,
                      //         style: TextStyle(color: Color(0xff1F4C6B)),
                      //       ),
                      //     ),
                      //   ],
                      // ),
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
