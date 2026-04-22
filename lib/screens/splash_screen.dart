// screens/splash_screen.dart — INTEGRATED
// Auth gate: token exists → MainScreen, else → SignInScreen

import 'package:flutter/material.dart';
import '../config/storage_helper.dart';
import '../services/user_service.dart';
import '../widgets/logo.dart';
import '../config/app_colors.dart';
import 'main_screen.dart';
import 'sign_in_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final loggedIn = await StorageHelper.isLoggedIn();
    if (loggedIn) {
      // Background refresh — doesn't block navigation
      UserService.getMe();
      if (mounted) Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const MainScreen()));
    } else {
      if (mounted) Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const SignInScreen()));
    }
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
            Text('Healio',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: -0.5)),
            SizedBox(height: 52),
            CircularProgressIndicator(
                color: AppColors.primary, strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}