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
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  bool get _isValidEmail => _emailRegex.hasMatch(emailController.text.trim());

  bool get _hasPasswordLength =>
      passwordController.text.length >= 8;
  bool get _hasPasswordUppercase =>
      passwordController.text.contains(RegExp(r'[A-Z]'));
  bool get _hasPasswordLowercase =>
      passwordController.text.contains(RegExp(r'[a-z]'));
  bool get _hasPasswordDigit =>
      passwordController.text.contains(RegExp(r'[0-9]'));

  bool get _isPasswordValid =>
      _hasPasswordLength &&
          _hasPasswordUppercase &&
          _hasPasswordLowercase &&
          _hasPasswordDigit;

  bool areFieldsFilled() {
    return nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        phoneController.text.isNotEmpty;
  }
  @override
  void initState() {
    super.initState();
    passwordController.addListener(() => setState(() {}));
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
                const SizedBox(height: 30),

                Text(
                  l10n!.joinApplication,
                  textAlign: TextAlign.center,
                  style: theme.titleLarge!.copyWith(
                    fontSize: 30.0.sp(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  l10n.registerMessage,
                  textAlign: TextAlign.center,
                  style: theme.bodySmall!.copyWith(
                    fontSize: 18.0.sp(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.passwordRequirements,
                        style: theme.bodySmall!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _RequirementRow(
                        met: _hasPasswordLength,
                        label: l10n.passwordRequirementLength,
                      ),
                      _RequirementRow(
                        met: _hasPasswordUppercase,
                        label: l10n.passwordRequirementUppercase,
                      ),
                      _RequirementRow(
                        met: _hasPasswordLowercase,
                        label: l10n.passwordRequirementLowercase,
                      ),
                      _RequirementRow(
                        met: _hasPasswordDigit,
                        label: l10n.passwordRequirementDigit,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: phoneController,
                  hintText: l10n.phoneNumber,
                  keyboardType: TextInputType.numberWithOptions(),
                ),
                const SizedBox(height: 30),

                Center(
                  child: CustomButton(
                    title: l10n.register,
                      onTap: () {
                        if (!areFieldsFilled()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.pleaseFillAllFields,
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        if (!_isValidEmail) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.invalidEmail,
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        if (!_isPasswordValid) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.passwordTooWeak,
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChooseYourCharacterScreen(
                              email: emailController.text.trim(),
                              password: passwordController.text,
                              phoneNumber: phoneController.text.trim(),
                              name: nameController.text.trim(),
                            ),
                          ),
                        );
                      }
                  ),
                ),
                const SizedBox(height: 20),
                // Center(
                //   child: Text(
                //     l10n.orContinueWith,
                //     style: TextStyle(color: Colors.grey),
                //   ),
                // ),
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
class _RequirementRow extends StatelessWidget {
  const _RequirementRow({required this.met, required this.label});

  final bool met;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.cancel,
            size: 18,
            color: met ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: theme.bodySmall!.copyWith(
                color: met
                    ? Colors.green
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
