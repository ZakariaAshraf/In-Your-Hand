import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_your_hand/core/utils/screen_util.dart';
import 'package:in_your_hand/core/widgets/custom_button.dart';
import 'package:in_your_hand/core/widgets/custom_text_field.dart';
import 'package:in_your_hand/features/clients/data/clients_model.dart';
import 'package:in_your_hand/features/clients/presentation/cubit/clients_cubit.dart';

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
      prev is ClientsLoading && curr is ClientsSuccess,
      listener: (context, state) {
          Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(l10n.addClientTitle, style: theme.titleLarge),
        ),
        body: Column(
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
              child: CustomTextField(
                controller: phoneController,
                title: l10n.phone,
                hintText: l10n.phoneNumber,
              ),
            ),
            SizedBox(height: 20.h(context)),
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
                final isLoading = state is ClientsLoading;
                return CustomButton(
                  title: isLoading ? l10n.processing : l10n.saveClient,
                  onTap: (isNameEmpty || isLoading) ? null : () {
                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    final client = ClientModel(
                      userId: uid ?? "",
                      name: nameController.text,
                      notes: notesController.text,
                      phone: phoneController.text,
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
