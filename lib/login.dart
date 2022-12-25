import 'package:flutter/material.dart';
import 'package:kitticure/mainPage.dart';
import 'package:kitticure/posts.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool logIn = false, reg = false, ok = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kitticure',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: Navigator(
        pages: [
          MaterialPage(
            key: const ValueKey("HomeScreen"),
            child: LogOrRegister(
              onPressedLog: () {
                setState(() {
                  logIn = true;
                });
              },
              onPressedReg: () {
                setState(() {
                  reg = true;
                });
              },
            ),
          ),
          if (logIn)
            MaterialPage(
              key: const ValueKey("Login Page"),
              child: LogInWindow(
                onPressedOK: () {
                  setState(() {
                    ok = true;
                  });
                },
              ),
            ),
          if (reg)
            MaterialPage(
              key: const ValueKey("Register Page"),
              child: RegisterWindow(
                onPressedOK: () {
                  setState(() {
                    ok = true;
                  });
                },
              ),
            ),
          if (ok)
            const MaterialPage(
              key: ValueKey("Main Page"),
              child: MainPage(),
            )
        ],
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            return false;
          }

          setState(() {
            logIn = false;
            reg = false;
          });

          return true;
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
  const LogInWindow({super.key, required this.onPressedOK});
  final VoidCallback onPressedOK;

  @override
  State<LogInWindow> createState() => _LogInWindowState();
}

class _LogInWindowState extends State<LogInWindow> {
  TextEditingController loginController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kitticure")),
      body: Center(
        child: Column(
          children: [
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
                onPressed: () {
                  final user = Provider.of<Admin>(context, listen: false)
                      .findUser(loginController.text, passwordController.text);
                  Provider.of<Admin>(context, listen: false)
                      .setCurrentUser(user);
                  widget.onPressedOK();
                },
                child: const Text('OK'))
          ],
        ),
      ),
    );
  }
}

class RegisterWindow extends StatefulWidget {
  const RegisterWindow({super.key, required this.onPressedOK});
  final VoidCallback onPressedOK;

  @override
  State<RegisterWindow> createState() => _RegisterWindowState();
}

class _RegisterWindowState extends State<RegisterWindow> {
  TextEditingController loginController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final addUser = Provider.of<Admin>(context, listen: false).addUser;
    return Scaffold(
      appBar: AppBar(title: const Text("Kitticure")),
      body: Center(
        child: Column(
          children: [
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
                onPressed: () {
                  User user = User(
                      login: loginController.text,
                      password: passwordController.text);
                  Provider.of<Admin>(context, listen: false).addUser(user);
                  Provider.of<Admin>(context, listen: false)
                      .setCurrentUser(user);
                  widget.onPressedOK();
                },
                child: const Text('OK'))
          ],
        ),
      ),
    );
  }
}
