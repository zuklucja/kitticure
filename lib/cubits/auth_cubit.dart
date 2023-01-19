import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitticure/services/firestore_service.dart';

import '../services/auth_service.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.authService})
      : super(
          authService.isSignedIn
              ? SignedInState(email: authService.userEmail)
              : const SignedOutState(),
        );

  final AuthService authService;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(const SigningInState());
    try {
      if (email == "" || password == "") {
        emit(const TryingToSignInState(error: 'Wypełnij wszystkie pola!'));
        return;
      }
      final result = await authService.signInWithEmail(email, password);

      switch (result) {
        case SignInResult.success:
          emit(SignedInState(email: email));
          break;
        case SignInResult.invalidEmail:
          emit(const TryingToSignInState(error: 'Niepoprawny adres email'));
          break;
        case SignInResult.userDisabled:
          emit(const TryingToSignInState(error: 'Użytkownik zablokowany'));
          break;
        case SignInResult.userNotFound:
          emit(const TryingToSignInState(error: 'Użytkownik nie znaleziony'));
          break;
        case SignInResult.emailAlreadyInUse:
          emit(const TryingToSignInState(
              error: 'Adres email jest już zarejestrowany'));
          break;
        case SignInResult.wrongPassword:
          emit(const TryingToSignInState(error: 'Niepoprawne hasło'));
          break;
      }
    } catch (e) {
      emit(const TryingToSignInState(
          error: 'Coś poszło nie tak, spróbuj ponownie.'));
    }
  }

  Future<void> signUp({
    required String email,
    required String login,
    required String password,
  }) async {
    var firestore = Firestore();
    emit(const SigningInState());
    try {
      if (email == "" || login == "" || password == "") {
        emit(const TryingToSignUpState(error: 'Wypełnij wszystkie pola!'));
        return;
      }
      if (await firestore.doesLoginAlreadyExists(login)) {
        emit(const TryingToSignUpState(error: 'Wybrany login jest już zajęty'));
        return;
      }
      final result = await authService.signUpWithEmail(email, login, password);
      switch (result) {
        case SignUpResult.success:
          emit(SignedInState(email: email));
          break;
        case SignUpResult.emailAlreadyInUse:
          emit(const TryingToSignUpState(
              error: 'Adres email jest już zarejestrowany'));
          break;
        case SignUpResult.weakPassword:
          emit(const TryingToSignUpState(error: 'Za słabe hasło'));
          break;
      }
    } catch (e) {
      emit(const TryingToSignUpState(
          error: 'Coś poszło nie tak, spróbuj ponownie.'));
    }
  }

  Future<void> signOut() async {
    emit(const SigningInState());
    await authService.signOut();
    emit(const SignedOutState());
  }

  Future<void> goBack() async {
    emit(const SignedOutState());
  }

  Future<void> tryToSignIn() async {
    emit(const TryingToSignInState());
  }

  Future<void> tryToSignUp() async {
    emit(const TryingToSignUpState());
  }
}

abstract class AuthState {
  const AuthState(this.error);

  final String? error;
}

class SignedInState extends AuthState {
  const SignedInState({
    required this.email,
  }) : super('');

  final String email;
}

class SignedOutState extends AuthState {
  const SignedOutState({error}) : super(error);
}

class TryingToSignInState extends AuthState {
  const TryingToSignInState({error}) : super(error);
}

class TryingToSignUpState extends AuthState {
  const TryingToSignUpState({error}) : super(error);
}

class SigningInState extends AuthState {
  const SigningInState() : super('');
}
