import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_your_hand/core/generated/extentions.dart';
import 'package:in_your_hand/core/utils/screen_util.dart';
import 'package:in_your_hand/features/clients/data/clients_model.dart';
import 'package:in_your_hand/features/orders/data/order_model.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/orders_cubit.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel order;
  final ClientModel client;

  const OrderDetailsScreen({
    super.key,
    required this.order,
    required this.client,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  OrderStatus? _selectedStatus;

  final TextEditingController paymentController = TextEditingController();

  bool get hasStatusChanged =>
      _selectedStatus != null && _selectedStatus != widget.order.status;

  @override
  void initState() {
    _selectedStatus = widget.order.status;
    super.initState();
  }

  static String _statusLabel(BuildContext context, OrderStatus status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case OrderStatus.pending:
        return l10n.orderStatusPending;
      case OrderStatus.partial:
        return l10n.orderStatusPartial;
      case OrderStatus.paid:
        return l10n.orderStatusPaid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStatus = _selectedStatus ?? widget.order.status;
    var theme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final totalUnpaid = widget.order.totalAmount - widget.order.paidAmount;
    return BlocListener<OrdersCubit, OrdersState>(
      listenWhen: (prev, curr) =>
          prev is OrdersLoading && curr is OrdersSuccess,
      listener: (context, state) {
        Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.orderDetails, style: theme.titleLarge),
          // actions: [
          //   if (hasStatusChanged)
          //     TextButton(
          //       onPressed: () {
          //         // final newPaidAmount =
          //         //     widget.order.paidAmount + enteredPayment;
          //         //
          //         // context.read<OrdersCubit>().updateOrderPayment(
          //         //   widget.order.copyWith(
          //         //     paidAmount: newPaidAmount,
          //         //   ),
          //         // );
          //       },
          //       child: const Text(
          //         "Save",
          //         style: TextStyle(color: AppColors.primary),
          //       ),
          //     ),
          // ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: BoxBorder.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(22.r(context)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        widget.client.isDeleted == false
                            ? widget.client.name
                            : l10n.deletedClient,
                        style: theme.titleMedium,
                      ),
                      // client Name
                      subtitle: Text(
                        widget.order.description,
                        style: theme.bodySmall?.copyWith(
                          color: Colors.grey,
                          fontSize: 18.sp(context),
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 30.h(context),
                            width: 80.w(context),
                            decoration: BoxDecoration(
                              color: currentStatus.color,
                              borderRadius: BorderRadius.circular(
                                30.r(context),
                              ),
                            ),
                            // padding: EdgeInsets.all(12),
                            child: Center(
                              child: Text(
                                _statusLabel(context, _selectedStatus ?? widget.order.status),
                                style: theme.bodySmall!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    ListTile(
                      title: Text(
                        l10n.totalAmountLabel,
                        style: theme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      subtitle: Text(
                        "${widget.order.totalAmount}",
                        style: theme.displayMedium,
                      ),
                    ),
                    Divider(),
                    ListTile(
                      trailing: IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (dialogContext) {
                              final dialogL10n = AppLocalizations.of(dialogContext)!;
                              return AlertDialog(
                                title: Text(dialogL10n.addPayment),
                                content: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.8,
                                  height: MediaQuery.of(context).size.height * 0.1,
                                  child: CustomTextField(
                                    hintText: "0",
                                    controller: paymentController,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(dialogL10n.cancel, style: theme.titleMedium),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      final entered = double.tryParse(paymentController.text);
                                      if (entered == null || entered <= 0) return;
                                      final newPaidAmount =
                                          widget.order.paidAmount + entered;
                                      if (newPaidAmount > widget.order.totalAmount) return;
                                      context.read<OrdersCubit>().updateOrderPayment(
                                        widget.order.copyWith(
                                          paidAmount: newPaidAmount,
                                        ),
                                      );
                                      Navigator.pop(context);
                                    },
                                    style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.blue)),
                                    child: Text(dialogL10n.save, style: theme.titleMedium),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.add_circle, size: 40),
                        ),
                      ),
                      title: Text(
                        l10n.totalUnpaid,
                        style: theme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      subtitle: totalUnpaid == 0 ?Text(
                        "- $totalUnpaid",
                        style: theme.displaySmall,
                      ):Text(
                        "- $totalUnpaid",
                        style: theme.displaySmall!.copyWith(color: Colors.red),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      title: Text(
                        l10n.created,
                        style: theme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      subtitle: Text(
                        formatDate(widget.order.createdAt),
                        style: theme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(l10n.status, style: theme.titleMedium),
              ),
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
              //             selectedColor: state.color,
              //             backgroundColor: state.backgroundColor,
              //             side: BorderSide.none,
              //             showCheckmark: false,
              //             label: Text(
              //               state.name,
              //               style: TextStyle(
              //                 color: _selectedStatus == state
              //                     ? Colors.white
              //                     : Colors.grey,
              //               ),
              //             ),
              //             selected: _selectedStatus == state,
              //             onSelected: (selected) {
              //               setState(() {
              //                 _selectedStatus = state;
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Chip(
                  backgroundColor: widget.order.status.color,
                  side: BorderSide.none,
                  label: Text(
                    _statusLabel(context, widget.order.status),
                    style: TextStyle(color: Colors.white),
                  ),
                  labelStyle: TextStyle(
                    decoration: TextDecoration.none,
                    fontSize: 28.sp(context),
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 40.h(context)),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Center(
                  child: CustomButton(
                    title: l10n.deleteOrder,
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder: (dialogContext) {
                          final dialogL10n = AppLocalizations.of(dialogContext)!;
                          return BackdropFilter(
                            filter: ImageFilter.blur(sigmaY: 3, sigmaX: 3),
                            child: AlertDialog(
                              title: Text(dialogL10n.deleteOrder),
                              content: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: Text(dialogL10n.deleteOrderConfirm),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(dialogL10n.cancel, style: theme.titleMedium),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await context.read<OrdersCubit>().deleteOrder(
                                      widget.order,
                                    );
                                    Navigator.pop(context);
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
                    height: 70.h(context),
                    width: 330.w(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
