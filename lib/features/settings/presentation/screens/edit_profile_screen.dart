import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/business_logo_display.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../Cubit/user_cubit.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void dispose() {
    businessNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme=Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editProfile)),
      body: BlocConsumer<UserCubit, UserState>(
        listener: (context, state) {
          if (state is UserError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is! UserLoaded) {
            return Center(child: Text(l10n.tryAgain));
          }

          final profile = state.profile;

          if (businessNameController.text.isEmpty) {
            businessNameController.text = profile.businessName;
          }
          if (phoneController.text.isEmpty) {
            phoneController.text = profile.phone ?? '';
          }
          if (addressController.text.isEmpty) {
            addressController.text = profile.address ?? '';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Center(
                  child: CircleAvatar(
                    backgroundColor: const Color(0xffe8d4d4),
                    radius: 56,
                    child: ClipOval(
                      child: buildBusinessLogoDisplay(
                        logoLocalPath: profile.logoLocalPath,
                        size: 112,
                        fallback: Icon(
                          Icons.business_center_outlined,
                          size: 48,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () =>
                      context.read<UserCubit>().pickAndSaveBusinessLogo(),
                  icon: const Icon(Icons.photo_library_outlined,color: Colors.green,),
                  label: Text(l10n.editProfileChooseLogo,style: theme.titleSmall,),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: businessNameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelText: l10n.editProfileBusinessNameLabel,
                    prefixIcon: const Icon(Icons.storefront_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelText: l10n.phoneNumber,
                    prefixIcon: const Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: addressController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelText: l10n.editProfileAddressLabel,
                    prefixIcon: const Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  title: l10n.saveChanges,
                  onTap: () async {
                    final cubit = context.read<UserCubit>();
                    await cubit.updateBusinessProfile(
                      businessName: businessNameController.text,
                      phone: phoneController.text,
                      address: addressController.text,
                    );
                    if (!context.mounted) return;
                    if (cubit.state is UserLoaded) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

