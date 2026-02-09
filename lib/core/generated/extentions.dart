import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:in_your_hand/features/clients/data/clients_model.dart';

import '../../features/orders/data/order_model.dart';

extension OrderStatusUI on OrderStatus {
  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return Colors.orange;
      // case OrderStatus.done:
      //   return Colors.blue;
      case OrderStatus.paid:
        return Colors.green;
      case OrderStatus.partial:
        return Colors.red;
    }
  }

  Color get backgroundColor {
    return color.withOpacity(0.15);
  }
}

final defaultClient = ClientModel(
  userId: "1",
  name: "Unknown Client",
  createdAt: DateTime.now(),
);

String formatDate(DateTime date) {
  return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}
