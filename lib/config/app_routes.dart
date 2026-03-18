import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/sign_in_screen.dart';
import '../screens/sign_up_screen.dart';
import '../screens/otp_screen.dart';
import '../screens/formule_screen.dart';
import '../screens/medical_form_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/main_screen.dart';

class AppRoutes {
  // ── Route names ────────────────────────────────────────────────────────────
  static const splash        = '/';
  static const signIn        = '/sign-in';
  static const signUp        = '/sign-up';
  static const otp           = '/otp';
  static const formule       = '/formule';
  static const medicalForm   = '/medical-form';
  static const welcome       = '/welcome';
  static const forgotPassword = '/forgot-password';
  static const home          = '/home';

  // ── Route map ──────────────────────────────────────────────────────────────
  static Map<String, WidgetBuilder> get routes => {
    splash:         (_) => const SplashScreen(),
    signIn:         (_) => const SignInScreen(),
    signUp:         (_) => const SignUpScreen(),
    otp:            (_) => const OtpScreen(),
    formule:        (_) => const FormuleScreen(),
    medicalForm:    (_) => const MedicalFormScreen(),
    welcome:        (_) => const WelcomeScreen(),
    forgotPassword: (_) => const ForgotPasswordScreen(),
    home:           (_) => const MainScreen(),
  };
}