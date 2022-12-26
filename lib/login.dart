import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kitticure/mainPage.dart';
import 'package:kitticure/posts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth-cubit.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kitticure',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: LogOrRegister(
        onPressedLog: () {
          context.read<AuthCubit>().tryToSignIn();
        },
        onPressedReg: () {
          context.read<AuthCubit>().tryToSignUp();
        },
      ),
    );
  }
}

class LogOrRegister extends StatelessWidget {
  const LogOrRegister(
      {super.key, required this.onPressedLog, required this.onPressedReg});
  final VoidCallback onPressedLog;
  final VoidCallback onPressedReg;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kitticure")),
      body: Center(
        child: Column(
          children: [
            MaterialButton(
              onPressed: onPressedLog,
              child: const Text('Zaloguj się'),
            ),
            MaterialButton(
              onPressed: onPressedReg,
              child: const Text('Zarejestruj się'),
            ),
          ],
        ),
      ),
    );
  }
}

class LogInWindow extends StatefulWidget {
  const LogInWindow({super.key, required this.state});
  final AuthState state;

  @override
  State<LogInWindow> createState() => _LogInWindowState();
}

class _LogInWindowState extends State<LogInWindow> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Zaloguj się"),
        leading: IconButton(
          onPressed: () {
            context.read<AuthCubit>().goBack();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            TextField(
              autofocus: true,
              controller: emailController,
              obscureText: false,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Adres email'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Hasło'),
            ),
            MaterialButton(
                onPressed: () async {
                  context.read<AuthCubit>().signIn(
                      email: emailController.text,
                      password: passwordController.text);

                  // final user = Provider.of<Admin>(context, listen: false)
                  //     .findUser(emailController.text);
                  // Provider.of<Admin>(context, listen: false)
                  //     .setCurrentUser(user);
                },
                child: const Text('OK')),
            const SizedBox(height: 16),
            Text(widget.state.error ?? ''),
          ],
        ),
      ),
    );
  }
}

class RegisterWindow extends StatefulWidget {
  const RegisterWindow({super.key, required this.state});
  final AuthState state;

  @override
  State<RegisterWindow> createState() => _RegisterWindowState();
}

class _RegisterWindowState extends State<RegisterWindow> {
  TextEditingController emailController = TextEditingController();
  TextEditingController loginController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final addUser = Provider.of<Admin>(context, listen: false).addUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Zarejestruj się"),
        leading: IconButton(
          onPressed: () {
            context.read<AuthCubit>().goBack();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            TextField(
              autofocus: true,
              controller: emailController,
              obscureText: false,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Adres email'),
            ),
            TextField(
              autofocus: true,
              controller: loginController,
              obscureText: false,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Login'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Hasło'),
            ),
            MaterialButton(
              onPressed: () async {
                context.read<AuthCubit>().signUp(
                    email: emailController.text,
                    login: loginController.text,
                    password: passwordController.text);

                // Provider.of<Admin>(context, listen: false).setCurrentUser(user);
              },
              child: const Text('OK'),
            ),
            const SizedBox(height: 16),
            Text(widget.state.error ?? ''),
          ],
        ),
      ),
    );
  }
}
