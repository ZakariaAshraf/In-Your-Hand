import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_your_hand/core/utils/app_colors.dart';
import 'package:in_your_hand/core/utils/screen_util.dart';
import 'package:in_your_hand/features/clients/data/clients_model.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/clients_cubit.dart';

class EditClientScreen extends StatefulWidget {
  final ClientModel client;
  const EditClientScreen({super.key, required this.client});

  @override
  State<EditClientScreen> createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  late TextEditingController phoneController ;
  late TextEditingController nameController ;
  late TextEditingController notesController;
  @override
  void initState() {
    phoneController = TextEditingController(text: widget.client.phone);
    nameController = TextEditingController(text: widget.client.name);
    notesController = TextEditingController(text: widget.client.notes);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
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
        title: Text(l10n.editClient, style: theme.titleLarge),
        actions: [
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
            child: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) {
                    final dialogL10n = AppLocalizations.of(dialogContext)!;
                    return BackdropFilter(
                      filter: ImageFilter.blur(sigmaY: 3, sigmaX: 3),
                      child: AlertDialog(
                        title: Text(dialogL10n.deleteClient),
                        content: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: Text(dialogL10n.deleteClientConfirm),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: Text(dialogL10n.cancel, style: theme.titleMedium),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await context.read<ClientsCubit>().deleteClient(widget.client);
                              Navigator.pop(dialogContext);
                            },
                            style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.red)),
                            child: Text(dialogL10n.delete, style: theme.titleMedium),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              icon: Icon(Icons.delete_outline, color: Colors.red),
              iconSize: 25,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
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
              child: CustomTextField(
                controller: phoneController,
                title: l10n.phone,
                hintText: l10n.phoneNumber,
                keyboardType: TextInputType.number,
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
                  onTap: () {
                    final newClient = ClientModel(
                      userId: widget.client.userId,
                      name: nameController.text,
                      notes: notesController.text,
                      phone: phoneController.text,
                      createdAt: widget.client.createdAt,
                    );
                    context.read<ClientsCubit>().updateClient(widget.client,newClient);
                  },
                  height: 70.h(context),
                  width: 300.w(context),
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
