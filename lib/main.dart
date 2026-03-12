// main.dart

import 'package:flutter/material.dart';
import 'screens/sign_in_screen.dart';    // ← import your screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,  // removes the red "debug" banner
      title: 'Healio',
      home: const SignInScreen(),         // ← show this screen first
    );
  }
}