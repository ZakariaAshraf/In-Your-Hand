import 'package:flutter/material.dart';
import 'package:in_your_hand/core/generated/extentions.dart';
import 'package:in_your_hand/core/utils/screen_util.dart';
import 'package:in_your_hand/features/orders/data/order_model.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
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
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: InkWell(
        onTap: () {
          PersistentNavBarNavigator.pushNewScreen(
            context, screen: OrderDetailsScreen(order: order, client: client),withNavBar: false
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h(context)),
          child: ListTile(
            leading: Container(
              decoration: BoxDecoration(
                color: order.status.color,
                borderRadius: BorderRadius.circular(30.r(context)),
              ),
              width:7.w(context),

            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w(context)),
            title: Text(clientName, style: theme.titleMedium),
            subtitle: Text(
              order.description,
              style: theme.bodySmall?.copyWith(color: Colors.grey[700]),
            ),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(text: TextSpan(
                  style:theme.titleSmall!.copyWith(color: Colors.grey) ,
                  text: l10n.total,
                  children: [
                    TextSpan(text: "${order.totalAmount}",style:theme.titleMedium ),
                  ]
                )),
                // Text("total: ${order.totalAmount}", style: theme.titleMedium),
                SizedBox(height: 4.h(context)),
                RichText(text: TextSpan(
                    style:theme.titleSmall!.copyWith(color: Colors.grey) ,
                    text: l10n.paid,
                    children: [
                      TextSpan(text: "${order.totalPaid}",style:theme.titleMedium!.copyWith(color: order.status.color) ),
                    ]
                )),

                // Text("paid: ${order.totalPaid}", style: theme.titleMedium),

                // Container(
                //   padding: EdgeInsets.symmetric(horizontal: 8.w(context), vertical: 4.h(context)),
                //   decoration: BoxDecoration(
                //     color: order.status.color,
                //     borderRadius: BorderRadius.circular(30.r(context)),
                //   ),
                //   child: Text(
                //     _statusLabel(context, order.status),
                //     style: theme.bodySmall!.copyWith(
                //       fontWeight: FontWeight.bold,
                //       fontSize: 10,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
