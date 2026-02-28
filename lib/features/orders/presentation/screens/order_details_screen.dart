import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_your_hand/core/generated/extentions.dart';
import 'package:in_your_hand/core/utils/screen_util.dart';
import 'package:in_your_hand/features/clients/data/clients_model.dart';
import 'package:in_your_hand/features/orders/data/order_model.dart';
import 'package:in_your_hand/features/orders/presentation/screens/generate_pdf_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/utils/pdf_manger.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/payments_cubit.dart';
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
  late TextEditingController noteController;

  bool get hasStatusChanged =>
      _selectedStatus != null && _selectedStatus != widget.order.status;

  @override
  void initState() {
    _selectedStatus = widget.order.status;
    noteController=TextEditingController(text:widget.order.notes);
    context.read<PaymentsCubit>().loadPayments(widget.order.id);
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
  void dispose() {
    paymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStatus = _selectedStatus ?? widget.order.status;
    var theme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final totalUnpaid = widget.order.totalAmount - widget.order.totalPaid;
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
          //   IconButton(
          //     onPressed: () {
          //       // showPdfPreview(context);
          //       // Navigator.push(context, MaterialPageRoute(builder: (context) => GeneratePdfScreen(),));
          //     },
          //     icon: Icon(Icons.print),
          //   ),
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
                      leading: Container(
                        decoration: BoxDecoration(
                          color: widget.order.status.color,
                          borderRadius: BorderRadius.circular(30.r(context)),
                        ),
                        width: 7.w(context),
                      ),
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
                      trailing: widget.client.phone != ""
                          ? InkWell(
                              onTap: () async {
                                final phone = widget.client.phone
                                    ?.replaceAll('+', '')
                                    .replaceAll(':', '')
                                    .trim();
                                final encoded = Uri.encodeComponent(
                                  "السلام عليكم حضرتك عليك $totalUnpaid من اصل مبلغ ${widget.order.totalAmount} لاوردر بتاريخ يوم ${formatDate(widget.order.createdAt)}",
                                );
                                final url = Uri.parse(
                                  "https://wa.me/$phone?text=$encoded",
                                );

                                if (await canLaunchUrl(url)) {
                                  await launchUrl(
                                    url,
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              },
                          child: Container(
                                height: 60.h(context),
                                width: 120.w(context),
                                decoration: BoxDecoration(
                                  color: currentStatus.color.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(
                                    30.r(context),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    l10n.sendReminder,
                                    style: theme.bodySmall!.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : null,
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
                        style: theme.titleLarge!.copyWith(
                          fontSize: 34.sp(context),
                        ),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      trailing: IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (dialogContext) {
                              final dialogL10n = AppLocalizations.of(
                                dialogContext,
                              )!;
                              return AlertDialog(
                                title: Text(dialogL10n.addPayment,style: theme.titleLarge,),
                                content: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  height:
                                      MediaQuery.of(context).size.height * 0.1,
                                  child: CustomTextField(
                                    hintText: "0",
                                    controller: paymentController,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext),
                                    child: Text(
                                      dialogL10n.cancel,
                                      style: theme.titleMedium,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      final entered = double.tryParse(
                                        paymentController.text,
                                      );
                                      if (entered == null || entered <= 0)
                                        return;
                                      final newPaidAmount =
                                          widget.order.totalPaid + entered;
                                      if (newPaidAmount >
                                          widget.order.totalAmount) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              l10n
                                                  .totalPaidMustNotExceedTotalAmount,
                                            ),
                                          ),
                                        );
                                      }
                                      // context.read<OrdersCubit>().updateOrderPayment(
                                      //   widget.order.copyWith(
                                      //     paidAmount: newPaidAmount,
                                      //   ),
                                      // );
                                      context
                                          .read<PaymentsCubit>()
                                          .addPayment(
                                            orderId: widget.order.id,
                                            amount: entered,
                                          )
                                          .then((_) {
                                            context
                                                .read<OrdersCubit>()
                                                .getOrders();
                                          });
                                      Navigator.pop(dialogContext);
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                        Colors.blue,
                                      ),
                                    ),
                                    child: Text(
                                      dialogL10n.save,
                                      style: theme.titleMedium,
                                    ),
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
                      subtitle: totalUnpaid == 0 as num
                          ? Text("- 0", style: theme.displaySmall)
                          : Text(
                              "- $totalUnpaid",
                              style: theme.displaySmall!.copyWith(
                                color: Colors.red,
                              ),
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
                      trailing: InkWell(
                        onTap: () async {
                          showDialog(
                            context: context,
                            builder: (dialogContext) {
                              final dialogL10n = AppLocalizations.of(
                                dialogContext,
                              )!;
                              return AlertDialog(
                                title: Text(dialogL10n.addNote,style: theme.titleLarge,),
                                content: SizedBox(
                                  width:
                                  MediaQuery.of(context).size.width * 0.8,
                                  height:
                                  MediaQuery.of(context).size.height * 0.2,
                                  child: CustomTextField(
                                    maxLines: 3,
                                    hintText: dialogL10n.addYourNote,
                                    controller: noteController,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext),
                                    child: Text(
                                      dialogL10n.cancel,
                                      style: theme.titleMedium,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (noteController.text.trim().isEmpty) return;
                                      Navigator.pop(dialogContext);
                                      context.read<OrdersCubit>().updateOrderNote(
                                        widget.order.id,
                                        noteController.text,
                                      );
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                        Colors.blue,
                                      ),
                                    ),
                                    child: Text(
                                      dialogL10n.save,
                                      style: theme.titleMedium,
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          height: 60.h(context),
                          width: 120.w(context),
                          decoration: BoxDecoration(
                            // color: currentStatus.color.withOpacity(0.3),
                            color: Colors.green.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(
                              30.r(context),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "Add note 📝",
                              style: theme.titleSmall,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (widget.order.notes!=null)
                     Column(children: [ Divider(),
                       ListTile(
                         title: Text(
                           l10n.notes,
                           style: theme.bodySmall?.copyWith(
                             color: Colors.grey[700],
                           ),
                         ),
                         subtitle: Text(
                           "${widget.order.notes}",
                           style: theme.bodyMedium,
                         ),
                       ),],),
                    Divider(),
                    ExpansionTile(
                      title: Text(
                        l10n.paymentHistory,
                        style: theme.bodyLarge,
                      ),
                      children: [
                        BlocBuilder<PaymentsCubit, PaymentsState>(
                          builder: (context, state) {
                            if (state is PaymentsLoaded) {
                              if (state.payments.isEmpty) {
                                return SizedBox();
                              }

                              return Table(
                                border: TableBorder.all(
                                  color: Colors.grey.shade300,
                                ),
                                columnWidths: const {
                                  0: FlexColumnWidth(2),
                                  1: FlexColumnWidth(2),
                                },
                                children: [
                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                    ),
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Text(l10n.amountLabel),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Text(l10n.dateLabel),
                                      ),
                                    ],
                                  ),
                                  ...state.payments.map((payment) {
                                    return TableRow(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            payment.amount.toString(),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            formatDate(payment.createdAt),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ],
                              );
                            }

                            return SizedBox();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(l10n.status, style: theme.titleMedium),
              ),
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
              // FutureBuilder<double>(
              //   future: context.read<OrdersCubit>().getTotalPaid(widget.order.id),
              //   builder: (context, snapshot) {
              //     final paid = snapshot.data ?? 0;
              //     final total = widget.order.totalAmount;
              //
              //     OrderStatus status;
              //     if (paid == 0) {
              //       status = OrderStatus.pending;
              //     } else if (paid < total) {
              //       status = OrderStatus.partial;
              //     } else {
              //       status = OrderStatus.paid;
              //     }
              //
              //     return Padding(
              //       padding: const EdgeInsets.symmetric(horizontal: 14.0),
              //       child: Chip(
              //         backgroundColor: status.color,
              //         side: BorderSide.none,
              //         label: Text(
              //           _statusLabel(context, status),
              //           style: TextStyle(color: Colors.white),
              //         ),
              //         labelStyle: TextStyle(
              //           decoration: TextDecoration.none,
              //           fontSize: 28.sp(context),
              //           color: Colors.white,
              //         ),
              //       ),
              //     );
              //   },
              // ),
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
                          final dialogL10n = AppLocalizations.of(
                            dialogContext,
                          )!;
                          return BackdropFilter(
                            filter: ImageFilter.blur(sigmaY: 3, sigmaX: 3),
                            child: AlertDialog(
                              title: Text(dialogL10n.deleteOrder,style: theme.titleLarge!.copyWith(color: Colors.red),),
                              content: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: Text(dialogL10n.deleteOrderConfirm),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: Text(
                                    dialogL10n.cancel,
                                    style: theme.titleMedium,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await context
                                        .read<OrdersCubit>()
                                        .deleteOrder(widget.order);
                                    Navigator.pop(dialogContext);
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                      Colors.red,
                                    ),
                                  ),
                                  child: Text(
                                    dialogL10n.delete,
                                    style: theme.titleMedium,
                                  ),
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
