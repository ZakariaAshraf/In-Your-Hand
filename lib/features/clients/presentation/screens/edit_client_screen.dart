import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_your_hand/core/utils/app_colors.dart';
import 'package:in_your_hand/core/utils/screen_util.dart';
import 'package:in_your_hand/features/clients/data/clients_model.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../cubit/clients_cubit.dart';

class EditClientScreen extends StatelessWidget {
  final ClientModel client;
  const EditClientScreen({super.key, required this.client});
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    TextEditingController phoneController = TextEditingController(text: client.phone);
    TextEditingController nameController = TextEditingController(text: client.name);
    TextEditingController notesController = TextEditingController(text: client.notes);
    return BlocListener<ClientsCubit, ClientsState>(
      listenWhen: (prev, curr) =>
      prev is ClientsLoading && curr is ClientsSuccess,
      listener: (context, state) {
          Navigator.pop(context);
      },
  child: Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text("Edit Client", style: theme.titleLarge),
        actions: [
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.1),shape: BoxShape.circle,),
            child: IconButton(onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return BackdropFilter(
                    filter: ImageFilter.blur(sigmaY: 3, sigmaX: 3),
                    child: AlertDialog(
                      title: const Text("Delete Order"),
                      content: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        // height: MediaQuery.of(context).size.height * 0.1,
                        child: Text("Are you sure you want to delete this client"),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cancel",style: theme.titleMedium),
                        ),
                        ElevatedButton(
                          onPressed: () async{
                           await context.read<ClientsCubit>().deleteClient(client);
                            Navigator.pop(context);
                          },
                          style: ButtonStyle(backgroundColor:WidgetStatePropertyAll(Colors.red) ),
                          child: Text("Delete",style: theme.titleMedium,),
                        ),
                      ],
                    ),
                  );
                },
              );
            }, icon: Icon(Icons.delete_outline,color: Colors.red,),iconSize: 25,),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: CustomTextField(
              controller: nameController,
              title: "Name",
              hintText: "Client Name",
            ),
          ),
          SizedBox(height: 20.h(context)),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: CustomTextField(
              controller: phoneController,
              title: "Phone",
              hintText: "Phone Number",
            ),
          ),
          SizedBox(height: 20.h(context)),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: CustomTextField(
              maxLines: 3,
              controller: notesController,
              title: "Notes",
              hintText: "Notes about this client",
            ),
          ),
          SizedBox(height: 20.h(context)),
          BlocBuilder<ClientsCubit, ClientsState>(
            builder: (context, state) {
              final isLoading = state is ClientsLoading;
              return CustomButton(
                title: isLoading ? "Processing" : " ✓ Save Client",
                onTap: () {
                  final newClient = ClientModel(
                    userId: client.userId,
                    name: nameController.text,
                    notes: notesController.text,
                    phone: phoneController.text,
                    createdAt: DateTime.now(),
                  );
                  context.read<ClientsCubit>().updateClient(client,newClient);
                },
                height: 70.h(context),
                width: 300.w(context),
              );
            },
          ),
        ],
      ),
    ),
);
  }
}
