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
  final String? notes;

  // final double paidAmount;
  final double totalPaid;

  // final OrderStatus status;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.clientId,
    required this.description,
    required this.totalAmount,
    this.notes,
    // required this.paidAmount,
    required this.totalPaid,
    // required this.status,
    required this.createdAt,
  });
  /// From Firestore
  factory OrderModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final total = (data['totalAmount'] ?? data['amount'] ?? 0) as num;
    // final paid = (data['paidAmount'] ?? 0) as num;
    final totalPaid = (data['totalPaid'] ?? 0) as num;

    return OrderModel(
      id: doc.id,
      userId: data['userId'],
      clientId: data['clientId'],
      description: data['description'],
      notes: data['notes'],
      totalAmount: total.toDouble(),
      // paidAmount: paid.toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      totalPaid: totalPaid.toDouble(),
    );
  }


  /// To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'clientId': clientId,
      'description': description,
      'totalAmount': totalAmount,
      'totalPaid': totalPaid,
      'notes': notes,
      // 'paidAmount': paidAmount,
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
      // paidAmount: paidAmount ?? this.paidAmount,
      createdAt: createdAt ?? this.createdAt, totalPaid: totalPaid ?? this.totalPaid,
    );
  }

  bool get isValidPayment =>
      totalPaid >= 0 && totalPaid <= totalAmount;

  double get remainingAmount => totalAmount - totalPaid;
  // OrderStatus get status {
  //   if (paidAmount == 0) return OrderStatus.pending;
  //   if (paidAmount < totalAmount) return OrderStatus.partial;
  //   return OrderStatus.paid;
  // }
  // OrderStatus get status {
  //   if (totalPaid == 0) return OrderStatus.pending;
  //   if (totalPaid < totalAmount) return OrderStatus.partial;
  //   return OrderStatus.paid;
  // }

  OrderStatus get status {
    if (totalPaid == 0) return OrderStatus.pending;
    if (totalPaid < totalAmount) return OrderStatus.partial;
    return OrderStatus.paid;
  }

  static OrderStatus _statusFromString(String status) {
    return OrderStatus.values.firstWhere(
          (e) => e.name == status,
      orElse: () => OrderStatus.pending,
    );
  }
}
