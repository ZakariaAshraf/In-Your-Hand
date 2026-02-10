import 'package:flutter/material.dart';
import 'package:in_your_hand/core/generated/extentions.dart';
import 'package:in_your_hand/core/utils/screen_util.dart';
import 'package:in_your_hand/features/orders/data/order_model.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../clients/data/clients_model.dart';
import '../screens/order_details_screen.dart';

class OrderItem extends StatelessWidget {
  final OrderModel order;
  final ClientModel client;
  final String clientName;
  const OrderItem({super.key, required this.order, required this.client, required this.clientName});

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
    var theme = Theme.of(context).textTheme;
    return Card(
      child:  SizedBox(
        height: 90,
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailsScreen(order: order,client:client),));
          },
          child: ClipRect(
            child: ListTile(
              title: Text(clientName, style: theme.titleMedium),
              subtitle: Text(
                order.description,
                style: theme.bodySmall?.copyWith(color: Colors.grey[700]),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("${order.totalAmount}", style: theme.titleMedium),
                  SizedBox(height: 10.h(context),),
                  Container(
                    height: 30.h(context),
                    width: 80.w(context),
                    decoration: BoxDecoration(
                      color: order.status.color,
                      borderRadius: BorderRadius.circular(30.r(context)),
                    ),
                    // padding: EdgeInsets.all(12),
                    child: Center(child: Text(_statusLabel(context, order.status), style: theme.bodySmall!.copyWith(fontWeight: FontWeight.bold),)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
