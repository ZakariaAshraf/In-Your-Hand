import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> signInWithEmailAndPassword(String email, String password);
  Future<UserEntity?> registerWithEmailAndPassword(String email, String password);
  Future<UserEntity?> signInWithGoogle();
  Future<bool> userDocumentExists(String uid);
  Future<void> completeGoogleProfile(
    String uid,
    String name,
    String phone,
    String? character,
  );
  Future<void> signOut();
}