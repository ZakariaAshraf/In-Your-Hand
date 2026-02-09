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