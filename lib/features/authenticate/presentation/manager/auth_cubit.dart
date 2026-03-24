import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import '../../../../core/cache/cache_helper.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/use_cases/auth_usecases.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignInUseCase signInUseCase;
  final RegisterUseCase registerUseCase;

  AuthCubit({required this.signInUseCase, required this.registerUseCase})
      : super(AuthInitial());

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

  Future<void> saveUserData({
    required String name,
    required String phone,
    String? character,
  }) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection("users").doc(userId).set({
        'name': name,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
        'character': character,
        'isPremium': false,
        'voiceOrdersUsed': 0,
        'voiceOrdersResetDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      emit(AuthFailure("Error saving user data: $e"));
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
       await saveUserData(name: name, phone: phone,character: characterPath);
      await CacheHelper.set(key: CacheKeys.uId, value: user!.id);
      await CacheHelper.set(key: CacheKeys.userName, value: name);
      await CacheHelper.set(key: CacheKeys.userCharacter, value: characterPath);
      await CacheHelper.set(key: CacheKeys.userPhone, value: phone);
      emit(AuthSuccess(user: user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  void signOut() async{
    await FirebaseAuth.instance.signOut();
    await CacheHelper.remove(key: CacheKeys.uId);
    await CacheHelper.remove(key: CacheKeys.userName);
    await CacheHelper.remove(key: CacheKeys.userCharacter);
    await CacheHelper.remove(key: CacheKeys.userPhone);
    emit(AuthInitial());
  }
}
