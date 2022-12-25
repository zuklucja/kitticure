import 'package:flutter/material.dart';
import 'package:kitticure/login.dart';
import 'package:kitticure/posts.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: ((context) => Admin()),
      child: const LoginPage(),
    ),
  );
}
