// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum SignInResult {
  invalidEmail,
  userDisabled,
  userNotFound,
  emailAlreadyInUse,
  wrongPassword,
  success,
}

enum SignUpResult {
  emailAlreadyInUse,
  weakPassword,
  success,
}

class AuthService {
  const AuthService({required FirebaseAuth firebaseAuth})
      : _firebaseAuth = firebaseAuth;

  final FirebaseAuth _firebaseAuth;

  bool get isSignedIn => _firebaseAuth.currentUser != null;
  Stream<bool> get isSignedInStream =>
      _firebaseAuth.userChanges().map((user) => user != null);
  String get userEmail => _firebaseAuth.currentUser!.email!;

  Future<SignInResult> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      if (isSignedIn) {
        await _firebaseAuth.signOut();
      }

      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return SignInResult.success;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        return SignInResult.invalidEmail;
      } else if (e.code == 'email-already-in-use') {
        return SignInResult.emailAlreadyInUse;
      } else if (e.code == 'user-disabled') {
        return SignInResult.userDisabled;
      } else if (e.code == 'user-not-found') {
        return SignInResult.userNotFound;
      } else if (e.code == 'wrong-password') {
        return SignInResult.wrongPassword;
      } else {
        print(e);
        rethrow;
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<SignUpResult> signUpWithEmail(
    String email,
    String login,
    String password,
  ) async {
    try {
      if (isSignedIn) {
        await _firebaseAuth.signOut();
      }

      User? user = (await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ))
          .user;

      if (user != null) {
        CollectionReference users =
            FirebaseFirestore.instance.collection('users');
        users
            .add({
              'login': login,
              'email': email,
            })
            .then((value) => print("User Added"))
            .catchError((error) => print("Failed to add user: $error"));
      }

      return SignUpResult.success;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return SignUpResult.weakPassword;
      } else if (e.code == 'email-already-in-use') {
        return SignUpResult.emailAlreadyInUse;
      }
      rethrow;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> signOut() => _firebaseAuth.signOut();
}
