import 'package:cloud_firestore/cloud_firestore.dart';

class ClientModel {
  final String ?id;
  final String userId;
  final String name;
  final String? phone;
  final String? notes;
  final DateTime createdAt;
  final bool isDeleted;
  ClientModel({
     this.id,
    required this.userId,
    required this.name,
    this.phone,
    this.notes,
    required this.createdAt,
    this.isDeleted =false,
  });

  /// From Firestore
  factory ClientModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data()!;
    return ClientModel(
      id: doc.id,
      userId: data['userId'],
      name: data['name'],
      phone: data['phone'],
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(), isDeleted: data['isDeleted'] ?? false,
    );
  }

  /// To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'phone': phone,
      'notes': notes,
      'isDeleted': isDeleted,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
