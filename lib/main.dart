import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitticure/auth-gate.dart';
import 'package:kitticure/login.dart';
import 'package:kitticure/posts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth-cubit.dart';
import 'auth-service.dart';
import 'firebase_options.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    Provider(
      create: (_) => AuthService(
        firebaseAuth: FirebaseAuth.instance,
      ),
      child: ChangeNotifierProvider(
        create: ((context) => Admin()),
        child: BlocProvider(
          create: (context) => AuthCubit(
            authService: context.read(),
          ),
          child: MaterialApp(
            home: Scaffold(
              body: const AuthGate(),
            ),
          ),
        ),
      ),
    ),
  );
}
