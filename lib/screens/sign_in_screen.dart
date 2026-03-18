import 'package:flutter/material.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';
import '../widgets/healio_logo.dart';
import '../widgets/top_bubbles.dart';
import '../config/app_colors.dart';
import 'sign_up_screen.dart';
import '../config/validators.dart';
import 'forgot_password_screen.dart';
import 'main_screen.dart'; // ← import dashboard

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _phoneError;
  String? _passwordError;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    setState(() {
      _phoneError = null;
      _passwordError = null;
    });

    setState(() {
      _phoneError = Validators.phone(_phoneController.text);
      _passwordError = Validators.password(_passwordController.text);
    });
    if (_phoneError != null || _passwordError != null) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isLoading = false);

    if (!mounted) return;

    // ── Go directly to dashboard (no token check for testing) ──────────────
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

                  AppTextField(
                    controller: _phoneController,
                    hint: 'Entrez votre numéro de téléphone',
                    keyboardType: TextInputType.phone,
                    errorText: _phoneError,
                    onChanged: (_) => setState(() => _phoneError = null),
                  ),

                  const SizedBox(height: 16),

                  AppTextField(
                    controller: _passwordController,
                    hint: 'Entrez votre mot de passe',
                    obscureText: true,
                    errorText: _passwordError,
                    onChanged: (_) => setState(() => _passwordError = null),
                  ),

                  const SizedBox(height: 28),

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
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
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