import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository authRepository;

  SignInUseCase(this.authRepository);

  Future<UserEntity?> execute(String email, String password) async {
    return await authRepository.signInWithEmailAndPassword(email, password);
  }
}

class RegisterUseCase {
  final AuthRepository authRepository;

  RegisterUseCase(this.authRepository);

  Future<UserEntity?> execute(String email, String password) async {
    return await authRepository.registerWithEmailAndPassword(email, password);
  }
}

class SignInWithGoogleUseCase {
  final AuthRepository _authRepository;

  SignInWithGoogleUseCase(this._authRepository);

  Future<UserEntity?> execute() => _authRepository.signInWithGoogle();
}

class UserDocumentExistsUseCase {
  final AuthRepository _authRepository;

  UserDocumentExistsUseCase(this._authRepository);

  Future<bool> execute(String uid) => _authRepository.userDocumentExists(uid);
}

class CompleteGoogleProfileUseCase {
  final AuthRepository _authRepository;

  CompleteGoogleProfileUseCase(this._authRepository);

  Future<void> execute(
    String uid,
    String name,
    String phone,
    String? character,
  ) =>
      _authRepository.completeGoogleProfile(uid, name, phone, character);
}

class SignOutUseCase {
  final AuthRepository _authRepository;

  SignOutUseCase(this._authRepository);

  Future<void> execute() => _authRepository.signOut();
}