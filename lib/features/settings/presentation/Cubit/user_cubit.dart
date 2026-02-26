import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import '../../../../core/cache/cache_helper.dart';
import '../../../../core/data/app_user_model.dart';
part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription? _userSubscription;

  void listenToUserData() {
    emit(UserLoading());
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      emit(UserError("User not logged in."));
      return;
    }

    final userDocStream = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots();

    _userSubscription?.cancel();

    _userSubscription = userDocStream.listen(
      (snapshot) {
        if (snapshot.exists) {
          final user = AppUserModel.fromFirestore(snapshot);
          CacheHelper.set(key: CacheKeys.userName, value: user.name);
          CacheHelper.set(key: CacheKeys.userPhone, value: user.phone);
          CacheHelper.set(key: CacheKeys.userCharacter, value: user.charUrl);
          emit(UserLoaded(user));
        } else {
          emit(UserError("User data not found."));
        }
      },
      onError: (error) {
        emit(UserError("Failed to load user data: ${error.toString()}"));
      },
    );
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }

  getCurrentUserData() async {
    try {
      emit(UserLoading());

      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference userDocRef = FirebaseFirestore.instance
          .collection("users")
          .doc(userId);

      DocumentSnapshot doc = await userDocRef.get();

      if (doc.exists) {
        user = AppUserModel.fromFirestore(doc);
        CacheHelper.set(key: CacheKeys.userName, value: user?.name);
        CacheHelper.set(key: CacheKeys.userPhone, value: user?.phone);
        CacheHelper.set(key: CacheKeys.userCharacter, value: user?.charUrl);
        emit(UserLoaded(user!));
      } else {
        emit(UserError("No user data found for the current user"));
      }
    } catch (e) {
      emit(UserError("Error retrieving user data: $e"));
    }
  }
  void loadUserData() {
    String? cachedName = CacheHelper.getString(key: CacheKeys.userName);
    String? cachedPhone = CacheHelper.getString(key: CacheKeys.userPhone);
    String? cachedImage = CacheHelper.getString(key: CacheKeys.userCharacter);

    if (cachedName != null) {
      final cachedUser = AppUserModel(
        name: cachedName,
        phone: cachedPhone ?? "",
        charUrl: cachedImage ??"",
        createdAt: DateTime.now(),
      );
      emit(UserLoaded(cachedUser));
    } else {
      emit(UserLoading());
    }
  }

  void listenToFirebaseStream(String userId) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    _userSubscription?.cancel();
    _userSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final user = AppUserModel.fromFirestore(snapshot);

        CacheHelper.set(key: CacheKeys.userName, value: user.name);
        CacheHelper.set(key: CacheKeys.userCharacter, value: user.charUrl);
        emit(UserLoaded(user));
      }
    });
  }

  AppUserModel? user;

  Future<void> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? charPath,
    // double? balance,
  }) async {
    emit(UserLoading());
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }


      final Map<String, dynamic> updatedData = {
        if (fullName != null) 'name': fullName,
        if (phoneNumber != null) 'phone': phoneNumber,
        if (charPath != null) 'character': charPath,
      };

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .update(updatedData);

      user = AppUserModel(
        name: fullName ?? user?.name ?? '',
        phone: phoneNumber ?? user?.phone ?? '',
        charUrl: charPath ?? user?.charUrl ?? '',
        createdAt: user?.createdAt ?? DateTime.now(),
      );
      getCurrentUserData();
      emit(UserSuccess());
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
