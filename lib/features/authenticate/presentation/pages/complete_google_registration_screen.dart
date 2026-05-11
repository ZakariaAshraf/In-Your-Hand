import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_your_hand/core/utils/screen_util.dart';
import 'package:in_your_hand/core/widgets/character_item.dart';
import 'package:in_your_hand/core/widgets/custom_button.dart';
import 'package:in_your_hand/core/widgets/custom_text_field.dart';
import 'package:in_your_hand/features/authenticate/domain/entities/user_entity.dart';
import 'package:in_your_hand/features/authenticate/presentation/manager/auth_cubit.dart';
import 'package:in_your_hand/core/session/session_cubit.dart';
import 'package:in_your_hand/l10n/app_localizations.dart';
import 'package:in_your_hand/main_screen.dart';

class CompleteGoogleRegistrationScreen extends StatefulWidget {
  const CompleteGoogleRegistrationScreen({super.key, required this.user});

  final UserEntity user;

  @override
  State<CompleteGoogleRegistrationScreen> createState() =>
      _CompleteGoogleRegistrationScreenState();
}

class _CompleteGoogleRegistrationScreenState
    extends State<CompleteGoogleRegistrationScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  int _selectedCharacterIndex = -1;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _defaultName(widget.user));
    _phoneController = TextEditingController();
  }

  static String _defaultName(UserEntity user) {
    final fromGoogle = user.displayName?.trim();
    if (fromGoogle != null && fromGoogle.isNotEmpty) {
      return fromGoogle;
    }
    final email = user.email.trim();
    if (email.contains('@')) {
      return email.split('@').first;
    }
    return email;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context).textTheme;

    final characters = <CharacterModel>[
      CharacterModel(
        id: 'male_busi',
        imagePath: 'assets/icons/mbusi.png',
        imageName: l10n.businessMan,
      ),
      CharacterModel(
        id: 'female_busi',
        imagePath: 'assets/icons/fbusi.png',
        imageName: l10n.businessWoman,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.completeRegistration),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) async {
          if (state is AuthSuccess) {
            // Switch session to authenticated uid and refresh dependents.
            await context.read<SessionCubit>().refresh();
            if (!context.mounted) return;
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil<void>(
              MaterialPageRoute<void>(builder: (_) => const MainScreen()),
              (route) => false,
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.googleProfileCompleteFailed),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.googleProfileTitle,
                  textAlign: TextAlign.center,
                  style: theme.titleLarge?.copyWith(
                    fontSize: 26.sp(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h(context)),
                Text(
                  l10n.googleProfileSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.bodyMedium?.copyWith(
                    fontSize: 15.sp(context),
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 28.h(context)),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    l10n.accountNameHint,
                    style: theme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _nameController,
                  hintText: l10n.fullName,
                ),
                SizedBox(height: 20.h(context)),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    l10n.phoneNumber,
                    style: theme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _phoneController,
                  hintText: l10n.phoneNumber,
                  keyboardType: const TextInputType.numberWithOptions(),
                ),
                SizedBox(height: 28.h(context)),
                Text(
                  l10n.chooseYourCharacter,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.sp(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h(context)),
                Text(
                  l10n.chooseCharacterDescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp(context),
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 16.h(context)),
                SizedBox(
                  height: 360.h(context),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: characters.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemBuilder: (context, index) {
                      return CharacterItem(
                        character: characters[index],
                        isSelected: _selectedCharacterIndex == index,
                        onTap: () {
                          setState(() => _selectedCharacterIndex = index);
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: 24.h(context)),
                Center(
                  child: CustomButton(
                    title: l10n.completeRegistration,
                    width: 300.w(context),
                    onTap: () {
                      final phone = _phoneController.text.trim();
                      final name = _nameController.text.trim();
                      if (name.isEmpty || phone.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.pleaseFillAllFields)),
                        );
                        return;
                      }
                      if (_selectedCharacterIndex < 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.pleaseSelectCharacter)),
                        );
                        return;
                      }
                      context.read<AuthCubit>().completeGoogleProfileFlow(
                            widget.user,
                            phone,
                            characters[_selectedCharacterIndex].id,
                            name,
                          );
                    },
                  ),
                ),
                SizedBox(height: 24.h(context)),
              ],
            ),
          );
        },
      ),
    );
  }
}
