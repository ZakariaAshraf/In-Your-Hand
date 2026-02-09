import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_your_hand/core/utils/screen_util.dart';
import 'package:in_your_hand/core/widgets/default_message_card.dart';
import 'package:in_your_hand/features/clients/data/clients_model.dart';
import 'package:in_your_hand/features/clients/presentation/cubit/clients_cubit.dart';
import 'package:in_your_hand/features/clients/presentation/cubit/clients_cubit.dart';
import 'package:in_your_hand/features/clients/presentation/screens/add_clients_screen.dart';
import 'package:in_your_hand/features/clients/presentation/widgets/clients_item.dart';

import '../../../../core/widgets/custom_button.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  @override
  void initState() {
    super.initState();

  }
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var theme = Theme
        .of(context)
        .textTheme;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Clients", style: theme.titleLarge),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search client...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase().trim();
                  });
                },
              ),
            ),
            SizedBox(
              height: 600.h(context),
              child: BlocBuilder<ClientsCubit, ClientsState>(
                builder: (context, state) {
                  if (state is ClientsLoading) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }  else if (state is ClientsError) {
                    DefaultMessageCard(sign: "😡", title: "Error", subTitle: state.errorMessage);
                  }else if (state is ClientsSuccess) {
                    final allClients = state.clients.where((c) => !c.isDeleted).toList();
                    final filteredClients = searchQuery.isEmpty
                        ? allClients
                        : allClients.where((client) {
                      return client.name.toLowerCase().contains(searchQuery);
                    }).toList();
                    // final visibleClients = clients
                    //     .where((client) => !client.isDeleted)
                    //     .toList();
                    if (filteredClients.isEmpty) {
                      return DefaultMessageCard(
                        sign: "🔍",
                        title: "No results",
                        subTitle: "No clients match your search",
                      );
                    }
                    return ListView.builder(
                      itemBuilder: (context, index) =>
                          ClientsItem(
                            client: filteredClients[index],
                          ),
                      itemCount:filteredClients.length,
                      physics: NeverScrollableScrollPhysics(),
                    );
                  }
                  return DefaultMessageCard(sign: "😊", title: "Empty List", subTitle: "You don't have any clients");

                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Center(
                child: CustomButton(
                  title: "+ Add Client",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AddClientsScreen(),));
                  },
                  height: 70.h(context),
                  width: 330.w(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
