// screens/sign_in_screen.dart — phone-based login, keeps original design

import 'package:flutter/material.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';
import '../widgets/healio_logo.dart';
import '../widgets/top_bubbles.dart';
import '../config/app_colors.dart';
import '../config/validators.dart';
import '../services/auth_service.dart';
import 'sign_up_screen.dart';
import 'forgot_password_screen.dart';
import 'main_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _phoneCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool    _isLoading    = false;
  String? _phoneError;
  String? _passwordError;
  String? _serverError;   // ← shows backend / network errors

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    // Clear previous errors
    setState(() {
      _phoneError    = null;
      _passwordError = null;
      _serverError   = null;
    });

    // Local validation first
    setState(() {
      _phoneError    = Validators.phone(_phoneCtrl.text);
      _passwordError = Validators.password(_passwordCtrl.text);
    });
    if (_phoneError != null || _passwordError != null) return;

    setState(() => _isLoading = true);

    // ── Backend call ────────────────────────────────────────────────
    final error = await AuthService.login(
      phone:    _phoneCtrl.text.trim(),
      password: _passwordCtrl.text,
      role:     'patient',
    );
    // ────────────────────────────────────────────────────────────────

    setState(() => _isLoading = false);

    if (error != null) {
      setState(() => _serverError = error);
      return;
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Your original background ──────────────────────────────
          const TopBubbles(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  const HealioLogo(),
                  const SizedBox(height: 65),

                  Text(
                    'SE CONNECTER',
                    style: TextStyle(
                      color: AppColors.primary.withValues(alpha: 0.85),
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 100),

                  Text(
                    'Toute votre santé, au même endroit',
                    style: TextStyle(color: AppColors.primary, fontSize: 13),
                  ),

                  const SizedBox(height: 28),

                  // Phone field
                  AppTextField(
                    controller: _phoneCtrl,
                    hint: 'Entrez votre numéro de téléphone',
                    keyboardType: TextInputType.phone,
                    errorText: _phoneError,
                    onChanged: (_) => setState(() {
                      _phoneError  = null;
                      _serverError = null;
                    }),
                  ),

                  const SizedBox(height: 16),

                  // Password field
                  AppTextField(
                    controller: _passwordCtrl,
                    hint: 'Entrez votre mot de passe',
                    obscureText: true,
                    errorText: _passwordError,
                    onChanged: (_) => setState(() {
                      _passwordError = null;
                      _serverError   = null;
                    }),
                  ),

                  // ── Server / network error ────────────────────────
                  if (_serverError != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.error, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _serverError!,
                              style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 12,
                                  height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // ── Your original AppButton (keeps isLoading) ─────
                  AppButton(
                    label: 'Se connecter',
                    isLoading: _isLoading,
                    onPressed: _onLoginPressed,
                  ),

                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen()),
                    ),
                    child: const Text(
                      'Mot de passe oublié ?',
                      style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
                    ),
                  ),

                  const SizedBox(height: 4),

                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    ),
                    child: Text(
                      "S'inscrire",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}