import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_your_hand/core/utils/screen_util.dart';
import 'package:in_your_hand/features/orders/presentation/widgets/order_item.dart';

import '../../../../core/utils/pdf_manger.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../orders/presentation/cubit/orders_cubit.dart';
import '../../data/clients_model.dart';

class ClientDetailsScreen extends StatefulWidget {
  final ClientModel client;

  const ClientDetailsScreen({super.key, required this.client});

  @override
  State<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen> {
  @override
  void initState() {
    if (widget.client.id != null) {
      context.read<OrdersCubit>().getClientOrders(widget.client.id!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(" ${l10n.clientReport}", style: theme.titleLarge),
        actions: [
          IconButton(
            onPressed: () {
              final state = context.read<OrdersCubit>().state;
              if (state is! OrdersSuccess || state.orders.isEmpty) {
                return;
              }
              showClientPdfPreview(
                context,
                client: widget.client,
                orders: state.orders,
              );
            },
            icon: Icon(Icons.print),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 40.h(context)),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Color(0xffe8d4d4),
                    radius: 60.r(context),
                    child: ClipOval(
                      child: Text(
                        widget.client.name[0],
                        style: theme.bodyLarge!.copyWith(
                          fontSize: 50.sp(context),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w(context)),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(widget.client.name, style: theme.titleLarge),
                    SizedBox(height: 8.h(context)),
                    if ((widget.client.phone ?? "").isNotEmpty)
                      Text(
                        widget.client.phone ?? "",
                        style: theme.titleLarge,
                      ),
                    SizedBox(height: 8.h(context)),
                    Text(
                      widget.client.notes ?? "",
                      style: theme.titleLarge,
                    ),
                  ],
                ),
              ],
            ),
            BlocBuilder<OrdersCubit, OrdersState>(
              builder: (context, state) {
                if (state is OrdersSuccess) {
                  final orders = state.orders;
                  final totalOrders = state.orders.length;

                  if (state.orders.isEmpty) {
                    return SizedBox.shrink();
                  }
                  final unpaidTotal = state.orders.fold<double>(
                    0,
                    (sum, o) => sum + o.remainingAmount,
                  );
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: BoxBorder.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.transparent,
                                        child: Text(
                                          l10n.egp,
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                      SizedBox(height: 8.h(context)),
                                      Text(
                                        "$unpaidTotal",
                                        style: theme.titleLarge!.copyWith(
                                          fontSize: 35.sp(context),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4.h(context)),
                                      Text(
                                        l10n.unpaid,
                                        style: theme.bodySmall!.copyWith(
                                          fontSize: 16.sp(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: BoxBorder.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.transparent,
                                        child: Icon(
                                          CupertinoIcons
                                              .list_bullet_below_rectangle,
                                          color: Colors.green,
                                        ),
                                      ),
                                      SizedBox(height: 8.h(context)),
                                      Text(
                                        "$totalOrders",
                                        style: theme.titleLarge!.copyWith(
                                          fontSize: 35.sp(context),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4.h(context)),
                                      Text(
                                        l10n.totalOrders,
                                        style: theme.bodySmall!.copyWith(
                                          fontSize: 16.sp(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return OrderItem(
                                order: orders[index],
                                client: widget.client,
                                clientName: widget.client.name,
                              );
                            },
                            itemCount: orders.length,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is OrdersLoading) {
                  return Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
