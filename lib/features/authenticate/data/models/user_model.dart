import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({required super.id, required super.email, super.displayName});

  factory UserModel.fromFirebaseUser(User user) {
    final email = user.email ??
        user.providerData
            .map((p) => p.email)
            .firstWhere((e) => e != null && e.isNotEmpty, orElse: () => null);
    return UserModel(
      id: user.uid,
      email: email ?? '',
      displayName: user.displayName,
    );
  }
}