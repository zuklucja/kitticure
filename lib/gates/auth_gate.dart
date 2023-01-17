import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitticure/cubits/auth_cubit.dart';
import 'package:kitticure/login_register.dart';

import '../main_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is SignedInState) {
          return MainPage(
            state: state,
          );
        } else if (state is SignedOutState) {
          return const LoginOrRegisterPage();
        } else if (state is TryingToSignInState) {
          return LogInWindow(
            state: state,
          );
        } else if (state is TryingToSignUpState) {
          return RegisterWindow(
            state: state,
          );
        } else if (state is SigningInState) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.brown,
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
