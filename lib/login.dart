import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:kitticure/auth_cubit.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kitticure',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text("Kitticure")),
        body: Center(
          child: Column(
            children: [
              MaterialButton(
                onPressed: () {
                  context.read<AuthCubit>().tryToSignIn();
                },
                child: const Text('Zaloguj się'),
              ),
              MaterialButton(
                onPressed: () {
                  context.read<AuthCubit>().tryToSignUp();
                },
                child: const Text('Zarejestruj się'),
              ),
            ],
          ),
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
