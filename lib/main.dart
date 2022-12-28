import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitticure/auth_gate.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth_cubit.dart';
import 'auth_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    Provider(
      create: (_) => AuthService(
        firebaseAuth: FirebaseAuth.instance,
      ),
      child: BlocProvider(
        create: (context) => AuthCubit(
          authService: context.read(),
        ),
        child: const MaterialApp(
          home: Scaffold(
            body: AuthGate(),
          ),
        ),
      ),
    ),
  );
}
