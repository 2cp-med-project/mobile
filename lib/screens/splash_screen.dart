// screens/splash_screen.dart
// First screen — checks token → redirects to sign_in or home automatically

import 'package:flutter/material.dart';
import '../config/storage_helper.dart';
import '../config/app_colors.dart';
import 'sign_in_screen.dart';
import '../widgets/healio_logo.dart';  

// import 'main/main_screen.dart'; q // TODO: uncomment when main_screen is ready

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    // small delay to show the splash logo
    await Future.delayed(const Duration(seconds: 2));

    final loggedIn = await StorageHelper.isLoggedIn();

    if (!mounted) return;

    if (loggedIn) {
      // TODO: replace with → Navigator.pushReplacementNamed(context, AppRoutes.home);
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (_) => const MainScreen()),
      // );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SignInScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // logo
            const HealioLogo(),

            const SizedBox(height: 48),

            // loading indicator
            CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}
