import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_your_hand/core/utils/screen_util.dart';
import 'package:in_your_hand/features/orders/data/order_model.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../clients/data/clients_model.dart';
import '../../../clients/presentation/cubit/clients_cubit.dart';
import '../cubit/orders_cubit.dart';

class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  TextEditingController totalAmountController = TextEditingController();
  TextEditingController paidAmountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isDescriptionEmpty = true;
  bool isAmountEmpty = true;
  String? _selectedClientName;
  String? _selectedClientId;
  // OrderStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    totalAmountController.addListener(() {
      setState(() => isAmountEmpty = totalAmountController.text.trim().isEmpty);
    });

    descriptionController.addListener(() {
      setState(
        () => isDescriptionEmpty = descriptionController.text.trim().isEmpty,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<OrdersCubit, OrdersState>(
      listenWhen: (prev, curr) =>
      prev is OrdersLoading && curr is OrdersSuccess,
      listener: (context, state) {
          Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(title: Text("Add Order", style: theme.titleLarge)),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Client", style: theme.titleSmall),
              ),
              BlocBuilder<ClientsCubit, ClientsState>(
                builder: (context, state) {
                  if (state is ClientsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ClientsSuccess) {
                    final clients = state.clients.where((c) => !c.isDeleted).toList();
                    if (clients.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text("No clients found"),
                      );
                    }
                    // return DropdownButtonFormField<String>(
                    //   value: _selectedClientId,
                    //   borderRadius: BorderRadius.circular(12),
                    //   decoration: const InputDecoration(
                    //     hintText: "Select a client",
                    //     border: InputBorder.none,
                    //     contentPadding: EdgeInsets.all(10),
                    //   ),
                    //   items: clients.map((client) {
                    //     return DropdownMenuItem(
                    //       value: client.id,
                    //       child: Text(client.name),
                    //     );
                    //   }).toList(),
                    //   onChanged: (value) {
                    //     setState(() {
                    //       _selectedClientId = value;
                    //     });
                    //   },
                    // );
                    return InkWell(
                      onTap: () {
                        _openClientSearchSheet(context,clients );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedClientName ?? "Select a client",
                              style: TextStyle(
                                color: _selectedClientName == null
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    );
                  }
                  if (state is ClientsError) {
                    return Text("Error loading clients");
                  }

                  return const SizedBox();
                },
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: CustomTextField(
                  controller: descriptionController,
                  title: "Description",
                  hintText: "What is the order for?",
                  maxLines: 3,
                ),
              ),
              SizedBox(height: 15.h(context)),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: CustomTextField(
                  controller: totalAmountController,
                  title: "Total Amount (\$) *",
                  hintText: "0",
                ),
              ),
              SizedBox(height: 15.h(context)),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: CustomTextField(
                  controller: paidAmountController,
                  title: "Paid Amount (\$)",
                  hintText: "0",
                ),
              ),
              SizedBox(height: 15.h(context)),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: Text("Status", style: theme.titleSmall),
              // ),
              // SizedBox(
              //   height: 60,
              //   child: ListView(
              //     scrollDirection: Axis.horizontal,
              //     children: [
              //       SizedBox(width: 8.w(context)),
              //       ...OrderStatus.values.map((state) {
              //         return Padding(
              //           padding: const EdgeInsets.symmetric(horizontal: 4.0),
              //           child: FilterChip(
              //             selectedColor: _selectedStatus?.color,
              //             backgroundColor: _selectedStatus?.backgroundColor,
              //             side: BorderSide.none,
              //             showCheckmark: false,
              //             label: Text(
              //               state.name,
              //               style: TextStyle(
              //                 color: _selectedStatus == state
              //                     ? Colors.white
              //                     : Colors.black,
              //               ),
              //             ),
              //             selected: _selectedStatus == state,
              //             onSelected: (selected) {
              //               setState(() {
              //                 _selectedStatus = selected ? state : null;
              //               });
              //               if (selected) {}
              //             },
              //             labelStyle: TextStyle(
              //               decoration: _selectedStatus == state
              //                   ? TextDecoration.none
              //                   : TextDecoration.none,
              //               // fontSize: _selectedStatus == state
              //               //     ? 18.sp(context)
              //               //     : 13.sp(context),
              //               fontSize: 28.sp(context),
              //               color: _selectedStatus == state
              //                   ? Colors.white
              //                   : Colors.black,
              //             ),
              //           ),
              //         );
              //       }),
              //       SizedBox(width: 8.w(context)),
              //     ],
              //   ),
              // ),
              // SizedBox(height: 20.h(context)),
              BlocBuilder<OrdersCubit, OrdersState>(
                builder: (context, state) {
                  final isLoading = state is OrdersLoading;
                  final total = double.tryParse(totalAmountController.text) ?? 0;
                  final paid = double.tryParse(paidAmountController.text) ?? 0;
                  bool isButtonDisabled =
                      isDescriptionEmpty ||
                          _selectedClientId == null ||
                          total <= 0 ||
                          paid < 0 ||
                          paid > total ||
                          isLoading;
                  return Center(
                    child: CustomButton(
                      title: isLoading ? "Processing" : " ✓ Save Order",
                      onTap: isButtonDisabled
                          ? null
                          : () {

                        final uid =
                                  FirebaseAuth.instance.currentUser?.uid;
                              final order = OrderModel(
                                userId: uid ?? "",
                                totalAmount: total,
                                paidAmount: paid,
                                description: descriptionController.text,
                                createdAt: DateTime.now(),
                                id: '',
                                clientId: _selectedClientId ?? "",
                                // status: _selectedStatus!,
                              );
                        if (!order.isValidPayment) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Paid amount cannot exceed total amount"),
                            ),
                          );
                          return;
                        }
                              context.read<OrdersCubit>().addOrder(order);
                            },
                      height: 70.h(context),
                      width: 330.w(context),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _openClientSearchSheet(
      BuildContext context,
      List<ClientModel> clients,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        TextEditingController searchController = TextEditingController();
        List<ClientModel> filteredClients = List.from(clients);

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),

                  /// drag handle
                  Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Search field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: "Search client...",
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setModalState(() {
                          filteredClients = clients
                              .where((c) => c.name
                              .toLowerCase()
                              .contains(value.toLowerCase().trim()))
                              .toList();
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// List
                  SizedBox(
                    height: 350,
                    child: filteredClients.isEmpty
                        ? const Center(child: Text("No clients found"))
                        : ListView.builder(
                      itemCount: filteredClients.length,
                      itemBuilder: (context, index) {
                        final client = filteredClients[index];
                        return ListTile(
                          title: Text(client.name),
                          onTap: () {
                            setState(() {
                              _selectedClientId = client.id;
                              _selectedClientName = client.name;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    descriptionController.dispose();
    totalAmountController.dispose();
    paidAmountController.dispose();
    super.dispose();
  }
}
