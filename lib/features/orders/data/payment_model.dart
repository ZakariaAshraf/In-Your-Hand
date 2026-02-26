import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String id;
  final double amount;
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.amount,
    required this.createdAt,
  });

  factory PaymentModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data()!;
    return PaymentModel(
      id: doc.id,
      amount: (data['amount'] as num).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
