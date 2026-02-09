import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  pending,
  partial,
  paid,
  // done,
}
enum OrdersFilter {
  all,
  pending,
  partial,
  // done,
  paid,
}

class OrderModel {
  final String id;
  final String userId;
  final String clientId;
  final String description;
  // final double amount;
  final double totalAmount;
  final double paidAmount;
  // final OrderStatus status;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.clientId,
    required this.description,
    required this.totalAmount,
    required this.paidAmount,
    // required this.status,
    required this.createdAt,
  });
  /// From Firestore
  factory OrderModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final total = (data['totalAmount'] ?? data['amount'] ?? 0) as num;
    final paid = (data['paidAmount'] ?? 0) as num;

    return OrderModel(
      id: doc.id,
      userId: data['userId'],
      clientId: data['clientId'],
      description: data['description'],
      totalAmount: total.toDouble(),
      paidAmount: paid.toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }


  /// To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'clientId': clientId,
      'description': description,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      // 'status': status.name, // pending / done / paid
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
  OrderModel copyWith({
    String? id,
    String? userId,
    String? clientId,
    String? description,
    double? totalAmount,
    double? paidAmount,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      clientId: clientId ?? this.clientId,
      description: description ?? this.description,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isValidPayment =>
      paidAmount >= 0 && paidAmount <= totalAmount;

  double get remainingAmount => totalAmount - paidAmount;
  OrderStatus get status {
    if (paidAmount == 0) return OrderStatus.pending;
    if (paidAmount < totalAmount) return OrderStatus.partial;
    return OrderStatus.paid;
  }
  static OrderStatus _statusFromString(String status) {
    return OrderStatus.values.firstWhere(
          (e) => e.name == status,
      orElse: () => OrderStatus.pending,
    );
  }
}
