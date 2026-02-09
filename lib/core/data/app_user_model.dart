import 'package:cloud_firestore/cloud_firestore.dart';

class AppUserModel {
  final String name;
  final String phone;
  final DateTime createdAt;
  final String charUrl;

  AppUserModel({
    required this.name,
    required this.phone,
    required this.createdAt,
    required this.charUrl,
  });

  factory AppUserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUserModel(
      name: data['name'],
      phone: data['phone'],
      createdAt: data['createdAt'].toDate(),
      charUrl: data['character'],
    );
  }
}