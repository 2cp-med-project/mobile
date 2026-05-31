// screens/splash_screen.dart
// Auth gate: token → check medical form → route correctly
// Flow:
//   No token         → SignInScreen
//   Token + no form  → MedicalFormScreen (can't skip)
//   Token + form     → MainScreen

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/storage_helper.dart';
import '../widgets/logo.dart';
import '../config/app_colors.dart';
import 'main_screen.dart';
import 'sign_in_screen.dart';
import 'medical_form_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    await Future.delayed(const Duration(milliseconds: 1200));

    final loggedIn = await StorageHelper.isLoggedIn();

    if (!loggedIn) {
      _go(const SignInScreen());
      return;
    }

    // already authenticated → go home
    _go(const MainScreen());
  }

  void _go(Widget screen) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Logo(),
            SizedBox(height: 16),
            Text(
              'Healio',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}
