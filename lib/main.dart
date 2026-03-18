// main.dart

import 'package:flutter/material.dart';
import 'config/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Healio',
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}