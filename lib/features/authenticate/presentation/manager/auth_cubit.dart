import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../../../core/cache/cache_helper.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/use_cases/auth_usecases.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignInUseCase signInUseCase;
  final RegisterUseCase registerUseCase;
  final CompleteGoogleProfileUseCase completeGoogleProfileUseCase;
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final UserDocumentExistsUseCase userDocumentExistsUseCase;
  final SignOutUseCase signOutUseCase;

  AuthCubit({
    required this.signInUseCase,
    required this.registerUseCase,
    required this.completeGoogleProfileUseCase,
    required this.signInWithGoogleUseCase,
    required this.userDocumentExistsUseCase,
    required this.signOutUseCase,
  }) : super(AuthInitial());

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await signInUseCase.execute(email, password);
      await CacheHelper.set(key: CacheKeys.uId, value: user!.id);
      emit(AuthSuccess(user: user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> register(
      {required String email,
      required String password,
      required String phone,
        String ?characterPath,
      required String name}) async {
    emit(AuthLoading());
    try {
      final user = await registerUseCase.execute(email, password);
      await completeGoogleProfileUseCase.execute(
        user!.id,
        name,
        phone,
        characterPath,
      );
      await CacheHelper.set(key: CacheKeys.uId, value: user.id);
      await CacheHelper.set(key: CacheKeys.userName, value: name);
      await CacheHelper.set(key: CacheKeys.userCharacter, value: characterPath);
      await CacheHelper.set(key: CacheKeys.userPhone, value: phone);
      emit(AuthSuccess(user: user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      final user = await signInWithGoogleUseCase.execute();
      if (user == null) {
        emit(AuthInitial());
        return;
      }

      final hasProfile = await userDocumentExistsUseCase.execute(user.id);
      if (hasProfile) {
        await CacheHelper.set(key: CacheKeys.uId, value: user.id);
        emit(AuthSuccess(user: user));
      } else {
        emit(AuthNeedsOnboarding(user: user));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> completeGoogleProfileFlow(
    UserEntity user,
    String phone,
    String? characterPath,
    String name,
  ) async {
    emit(AuthLoading());
    try {
      await completeGoogleProfileUseCase.execute(
        user.id,
        name,
        phone,
        characterPath,
      );
      await CacheHelper.set(key: CacheKeys.uId, value: user.id);
      await CacheHelper.set(key: CacheKeys.userName, value: name);
      await CacheHelper.set(
        key: CacheKeys.userCharacter,
        value: characterPath ?? '',
      );
      await CacheHelper.set(key: CacheKeys.userPhone, value: phone);
      emit(AuthSuccess(user: user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signOut() async {
    await signOutUseCase.execute();
    await CacheHelper.remove(key: CacheKeys.uId);
    await CacheHelper.remove(key: CacheKeys.userName);
    await CacheHelper.remove(key: CacheKeys.userCharacter);
    await CacheHelper.remove(key: CacheKeys.userPhone);
    emit(AuthInitial());
  }
}
