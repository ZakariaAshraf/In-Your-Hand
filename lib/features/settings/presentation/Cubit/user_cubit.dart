import 'dart:async';

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
        charUrl: cachedImage ?? "",
        createdAt: DateTime.now(),
        isPremium: false,
        voiceOrdersUsed: 0,
        voiceOrdersResetDate: null,
      );
      emit(UserLoaded(cachedUser));
    } else {
      emit(UserLoading());
    }
  }

  void listenToFirebaseStream(String userId) {
    if (userId.isEmpty) return;

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
        isPremium: user?.isPremium ?? false,
        voiceOrdersUsed: user?.voiceOrdersUsed ?? 0,
        voiceOrdersResetDate: user?.voiceOrdersResetDate,
      );
      getCurrentUserData();
      emit(UserSuccess());
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> incrementVoiceOrderUsage() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final snap = await docRef.get();
    if (!snap.exists) return;

    final data = snap.data()!;
    final now = DateTime.now();
    final resetDate = (data['voiceOrdersResetDate'] as Timestamp?)?.toDate();

    // If resetDate is more than 30 days ago, reset the counter
    final shouldReset =
        resetDate == null || now.difference(resetDate).inDays >= 30;

    await docRef.update({
      'voiceOrdersUsed': shouldReset ? 1 : FieldValue.increment(1),
      if (shouldReset) 'voiceOrdersResetDate': FieldValue.serverTimestamp(),
    });
  }

  /// Deletes all user data and the Auth account.
  /// [password] is required for email/password users so Firebase can
  /// [reauthenticateWithCredential] before [User.delete] (avoids
  /// `requires-recent-login`).
  Future<void> deleteAccount(String password) async {
    emit(UserLoading());
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      emit(UserError("User not logged in."));
      return;
    }

    final email = currentUser.email;
    if (email == null || email.isEmpty) {
      emit(UserError(
        "This sign-in method cannot delete the account from the app. "
        "Please contact support.",
      ));
      return;
    }

    if (password.isEmpty) {
      emit(UserError("Please enter your password."));
      return;
    }

    final userId = currentUser.uid;

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await currentUser.reauthenticateWithCredential(credential);

      final firestore = FirebaseFirestore.instance;

      final ordersSnapshot = await firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();

      for (var orderDoc in ordersSnapshot.docs) {
        final paymentsSnapshot = await orderDoc.reference
            .collection('payments')
            .get();

        for (var paymentDoc in paymentsSnapshot.docs) {
          await paymentDoc.reference.delete();
        }

        await orderDoc.reference.delete();
      }

      final clientsSnapshot = await firestore
          .collection('clients')
          .where('userId', isEqualTo: userId)
          .get();

      for (var clientDoc in clientsSnapshot.docs) {
        await clientDoc.reference.delete();
      }

      await firestore.collection('users').doc(userId).delete();

      await currentUser.delete();

      await CacheHelper.remove(key: CacheKeys.uId);
      await CacheHelper.remove(key: CacheKeys.userName);
      await CacheHelper.remove(key: CacheKeys.userPhone);
      await CacheHelper.remove(key: CacheKeys.userCharacter);

      await _auth.signOut();

      emit(UserAccountDeleted());

    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        emit(UserError(
          "Incorrect password. Please try again.",
        ));
      } else if (e.code == 'requires-recent-login') {
        emit(UserError(
          "For security, please sign out and sign in again, then try deleting your account.",
        ));
      } else {
        emit(UserError(e.message ?? "Error deleting account: ${e.code}"));
      }
    } catch (e) {
      emit(UserError("Error deleting account: $e"));
    }
  }
}
