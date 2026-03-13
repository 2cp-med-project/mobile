// screens/sign_in_screen.dart
// Login page — only screen logic here, all UI imported from widgets/

import 'package:flutter/material.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';
import '../widgets/healio_logo.dart';
import '../widgets/top_bubbles.dart';
import '../config/app_colors.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _phoneController    = TextEditingController();
  final _passwordController = TextEditingController();

  bool    _isLoading     = false;
  String? _phoneError;
  String? _passwordError;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    setState(() { _phoneError = null; _passwordError = null; });

    final phone    = _phoneController.text.trim();
    final password = _passwordController.text;

    bool hasError = false;
    if (phone.isEmpty || phone.length < 9) {
      setState(() => _phoneError = 'Essayez à nouveau');
      hasError = true;
    }
    if (password.isEmpty || password.length < 6) {
      setState(() => _passwordError = 'Invalid password');
      hasError = true;
    }
    if (hasError) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    // TODO: await AuthService.login(phone, password);
    // TODO: Navigator.pushReplacementNamed(context, AppRoutes.home);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [

          // background shapes — imported from widgets/top_bubbles.dart
          const TopBubbles(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),

                  // logo — imported from widgets/healio_logo.dart
                  const HealioLogo(),
                  const SizedBox(height: 60),

                  const SizedBox(height: 20),

                  Text(
                    'SE CONNECTER',
                    style: TextStyle(
                      color:         AppColors.primary.withValues(alpha: 0.85),
                      fontSize:      22,
                      fontWeight:    FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 80),

                  Text(
                    'Toute votre santé, au même endroit',
                    style: TextStyle(
                      color:    AppColors.primary,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // phone field — imported from widgets/app_text_field.dart
                  AppTextField(
                    controller:   _phoneController,
                    hint:         'Entrez votre numéro de téléphone',
                    keyboardType: TextInputType.phone,
                    errorText:    _phoneError,
                    onChanged:    (_) => setState(() => _phoneError = null),
                  ),

                  const SizedBox(height: 16),

                  // password field — same component, different props
                  AppTextField(
                    controller:  _passwordController,
                    hint:        'Entrez votre mot de passe',
                    obscureText: true,
                    errorText:   _passwordError,
                    onChanged:   (_) => setState(() => _passwordError = null),
                  ),

                  const SizedBox(height: 28),

                  AppButton(
                    label:     'Se connecter',
                    isLoading: _isLoading,
                    onPressed: _onLoginPressed,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Mot de passe oublié ?',
                    style: TextStyle(
                      color:    AppColors.textGrey,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 4),

                  GestureDetector(
                    onTap: () {
                      // TODO: Navigator.pushNamed(context, AppRoutes.signUp);
                    },
                    child: Text(
                      "S'inscrire",
                      style: TextStyle(
                        color:      AppColors.primary,
                        fontSize:   13,
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