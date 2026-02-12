import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_your_hand/core/generated/extentions.dart';
import 'package:in_your_hand/core/utils/app_colors.dart';
import 'package:in_your_hand/core/utils/screen_util.dart';
import 'package:in_your_hand/core/widgets/custom_button.dart';
import 'package:in_your_hand/features/orders/presentation/screens/add_order_screen.dart';
import 'package:in_your_hand/features/orders/presentation/widgets/order_item.dart';

import '../../../../core/widgets/default_message_card.dart';
import '../../../../l10n/app_localizations.dart';
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



  String _filterLabel(BuildContext context, OrdersFilter filter) {
    final l10n = AppLocalizations.of(context)!;
    switch (filter) {
      case OrdersFilter.all:
        return l10n.orderFilterAll;
      case OrdersFilter.pending:
        return l10n.orderFilterPending;
      case OrdersFilter.partial:
        return l10n.orderFilterPartial;
      case OrdersFilter.paid:
        return l10n.orderFilterPaid;
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            color: AppColors.primary,
            icon: Icon(Icons.add_circle, size: 33),
            // title: l10n.addOrder,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddOrderScreen()),
              );
            },
          ),
        ],
        title: Text(l10n.orders, style: theme.titleLarge),
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
                        label: Text(_filterLabel(context, filter)),
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
                    return DefaultMessageCard(
                      sign: "😡",
                      title: l10n.errorTitle,
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
                        title: l10n.noOrders,
                        subTitle: l10n.noOrdersForThisStatus,
                      );
                    } else {
                      return ListView.builder(
                        // physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        final client = context
                            .read<ClientsCubit>()
                            .clientsMap[order.clientId];
                        final clientName = client == null
                            ? l10n.unknownClient
                            : client.isDeleted
                            ? l10n.deletedClient
                            : client.name;
                        return OrderItem(
                          order: order,
                          client: client ?? defaultClient,
                          clientName: clientName,
                        );
                      },
                      itemCount: filteredOrders.length,
                    );
                    }
                    }
                  return DefaultMessageCard(
                    sign: "📭",
                    title: l10n.noOrders,
                    subTitle: l10n.youDontHaveAnyOrders,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
