import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_your_hand/core/generated/extentions.dart';
import 'package:in_your_hand/core/utils/app_colors.dart';
import 'package:in_your_hand/core/utils/screen_util.dart';
import 'package:in_your_hand/core/widgets/custom_button.dart';
import 'package:in_your_hand/features/orders/presentation/screens/add_order_screen.dart';
import 'package:in_your_hand/features/orders/presentation/widgets/order_item.dart';

import '../../../../core/widgets/default_message_card.dart';
import '../../../clients/presentation/cubit/clients_cubit.dart';
import '../../data/order_model.dart';
import '../cubit/orders_cubit.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  OrdersFilter _selectedFilter = OrdersFilter.all;



  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Orders", style: theme.titleLarge),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 60.h(context),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  SizedBox(width: 8.w(context)),
                  ...OrdersFilter.values.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(filter.name),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: Colors.grey.shade200,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                        onSelected: (_) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                      ),
                    );
                  }),
                  SizedBox(width: 8.w(context)),
                ],
              ),
            ),
            SizedBox(
              height: 600.h(context),
              child: BlocBuilder<OrdersCubit, OrdersState>(
                builder: (context, state) {
                  if (state is OrdersLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is OrdersError) {
                    DefaultMessageCard(
                      sign: "😡",
                      title: "Error",
                      subTitle: state.errorMessage,
                    );
                  } else if (state is OrdersSuccess) {
                    final orders = state.orders;
                    print("Orders fetched: ${orders.length}");
                    List filteredOrders = orders;
                    if (_selectedFilter != OrdersFilter.all) {
                      filteredOrders = orders.where((order) {
                        switch (_selectedFilter) {
                          case OrdersFilter.pending:
                            return order.status == OrderStatus.pending;
                          case OrdersFilter.partial:
                            return order.status == OrderStatus.partial;
                          case OrdersFilter.paid:
                            return order.status == OrderStatus.paid;
                          // case OrdersFilter.done:
                          //   return order.status == OrderStatus.done;
                          default:
                            return true;
                        }
                      }).toList();
                    }
                    if (filteredOrders.isEmpty) {
                      return DefaultMessageCard(
                        sign: "📭",
                        title: "No orders",
                        subTitle: "No orders for this status",
                      );
                    }else {
                      return ListView.builder(
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        final client = context
                            .read<ClientsCubit>()
                            .clientsMap[order.clientId];
                        final clientName = client == null
                            ? "Unknown Client"
                            : client.isDeleted
                            ? "Deleted Client"
                            : client.name;
                        return OrderItem(
                          order: order,
                          client: client ?? defaultClient,
                          clientName: clientName,
                        );
                      },
                      itemCount: filteredOrders.length,
                      physics: NeverScrollableScrollPhysics(),
                    );
                    }
                  }else if (state is OrdersError) {
                    DefaultMessageCard(
                      sign: "😡",
                      title: "Error",
                      subTitle: state.errorMessage,
                    );
                  }
                  return DefaultMessageCard(
                    sign: "📭",
                    title: "No orders",
                    subTitle: "You don't have any orders",
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Center(
                child: CustomButton(
                  title: "+ Add Order",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddOrderScreen()),
                    );
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
