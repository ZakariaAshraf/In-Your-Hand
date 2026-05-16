import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_your_hand/core/services/ad_manager.dart';
import 'package:in_your_hand/core/utils/screen_util.dart';
import 'package:in_your_hand/core/widgets/custom_button.dart';
import 'package:in_your_hand/core/widgets/custom_text_field.dart';
import 'package:in_your_hand/features/clients/data/clients_model.dart';
import 'package:in_your_hand/features/clients/presentation/cubit/clients_cubit.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class AddClientsScreen extends StatefulWidget {
  const AddClientsScreen({super.key});

  @override
  State<AddClientsScreen> createState() => _AddClientsScreenState();
}

class _AddClientsScreenState extends State<AddClientsScreen> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  bool isNameEmpty = true;
  String fullPhoneNumber = '';
  /// True from first tap until post-save interstitial (or error) completes — keeps button disabled while state is Success during ad load.
  bool _submitInFlight = false;

  @override
  void initState() {
    super.initState();
    nameController.addListener(() {
      setState(() {
        isNameEmpty = nameController.text
            .trim()
            .isEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme
        .of(context)
        .textTheme;
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<ClientsCubit, ClientsState>(
      listenWhen: (prev, curr) =>
          _submitInFlight &&
          prev is ClientsLoading &&
          (curr is ClientsSuccess || curr is ClientsError),
      listener: (context, state) async {
        if (!_submitInFlight) return;
        if (state is ClientsError) {
          if (mounted) {
            setState(() => _submitInFlight = false);
          }
          return;
        }
        try {
          await AdManager.showInterstitialAd();
        } catch (_) {}
        if (!context.mounted) return;
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(l10n.addClientTitle, style: theme.titleLarge),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: CustomTextField(
                controller: nameController,
                title: l10n.name,
                hintText: l10n.clientName,
              ),
            ),
            SizedBox(height: 20.h(context)),
            Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(text: TextSpan(text:l10n.phoneNumber,style: theme.titleSmall,children: [
                      // TextSpan(text:"add number without first 0",style: theme.bodySmall,)
                    ]),),
                    Text("🚨${l10n.addNumberWithoutFirst0}🚨",style: theme.bodySmall),
                    SizedBox(height: 4.h(context),),
                    IntlPhoneField(
                      textAlign: Directionality.of(context) == TextDirection.rtl ? TextAlign.right : TextAlign.left,
                      controller: phoneController,
                      decoration: InputDecoration(
                        hintText: l10n.phoneNumber,
                        hintStyle: theme.titleMedium!.copyWith(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular( 12),
                          borderSide: BorderSide(color: Colors.black.withOpacity(0.2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular( 12),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                      initialCountryCode: 'EG',
                      onChanged: (phone) {
                        fullPhoneNumber = phone.completeNumber;
                      },
                    ),
                  ],
                ),
              ),
            SizedBox(height: 10.h(context)),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: CustomTextField(
                maxLines: 3,
                controller: notesController,
                title: l10n.notes,
                hintText: l10n.notesAboutClient,
              ),
            ),
            SizedBox(height: 20.h(context)),
            BlocBuilder<ClientsCubit, ClientsState>(
              builder: (context, state) {
                final busy = _submitInFlight;
                return CustomButton(
                  title: l10n.saveClient,
                  isLoading: busy,
                  onTap: (isNameEmpty || busy)
                      ? null
                      : () {
                          setState(() => _submitInFlight = true);
                          final uid = FirebaseAuth.instance.currentUser?.uid;
                          final finalPhone = fullPhoneNumber.isNotEmpty
                              ? fullPhoneNumber
                              : phoneController.text;
                          final client = ClientModel(
                            userId: uid ?? "",
                            name: nameController.text,
                            notes: notesController.text,
                            phone: finalPhone,
                            createdAt: DateTime.now(),
                          );
                          context.read<ClientsCubit>().addClient(client);
                        },
                  height: 70.h(context),
                  width: 330.w(context),
                );
              },
            ),
          ],
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    notesController.dispose();
    super.dispose();
  }
}
