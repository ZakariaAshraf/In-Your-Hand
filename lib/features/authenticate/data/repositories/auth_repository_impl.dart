import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../google_sign_in_config.dart';
import '../models/user_model.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              serverClientId:
                  kIsWeb ? null : GoogleSignInWebClientId.value,
              clientId: kIsWeb ? GoogleSignInWebClientId.value : null,
              scopes: const ['email', 'profile'],
            );

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  @override
  Future<UserEntity?> signInWithEmailAndPassword(String email, String password) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return UserModel.fromFirebaseUser(userCredential.user!);
  }

  @override
  Future<UserEntity?> registerWithEmailAndPassword(String email, String password) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    return UserModel.fromFirebaseUser(userCredential.user!);
  }

  @override
  Future<UserEntity?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        return null;
      }

      return UserModel.fromFirebaseUser(user);
    } on PlatformException catch (e, st) {
      if (e.code == GoogleSignIn.kSignInCanceledError) {
        return null;
      }
      if (kDebugMode) {
        // ignore: avoid_print
        print('signInWithGoogle PlatformException: ${e.code} ${e.message}');
        print(st);
      }
      return null;
    } catch (e, st) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('signInWithGoogle: $e');
        print(st);
      }
      return null;
    }
  }

  @override
  Future<bool> userDocumentExists(String uid) async {
    final snapshot = await _firestore.collection('users').doc(uid).get();
    return snapshot.exists;
  }

  @override
  Future<void> completeGoogleProfile(
    String uid,
    String name,
    String phone,
    String? character,
  ) async {
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
      'character': character,
      'isPremium': false,
      'voiceOrdersUsed': 0,
      'voiceOrdersResetDate': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> signOut() async {
    await Future.wait<void>([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}
