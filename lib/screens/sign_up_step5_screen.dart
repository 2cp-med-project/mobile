// screens/sign_up_step5_screen.dart
// Sign up step 5 — créer mot de passe + confirmer

import 'package:flutter/material.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';
import '../widgets/healio_logo.dart';
import '../widgets/signup_bubbles.dart';
import 'sign_up_step6_screen.dart';
import 'otp_screen.dart';

class SignUpStep5Screen extends StatefulWidget {
  const SignUpStep5Screen({super.key});

  @override
  State<SignUpStep5Screen> createState() => _SignUpStep5ScreenState();
}

class _SignUpStep5ScreenState extends State<SignUpStep5Screen> {
  final _passwordController = TextEditingController();
  final _confirmController  = TextEditingController();

  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onSuivantePressed() {
    setState(() { _passwordError = null; _confirmError = null; });

    bool hasError = false;

    if (_passwordController.text.isEmpty || _passwordController.text.length < 8) {
      setState(() => _passwordError = 'Minimum 8 caractères');
      hasError = true;
    }
    if (_confirmController.text.isEmpty) {
      setState(() => _confirmError = 'Requis');
      hasError = true;
    } else if (_confirmController.text != _passwordController.text) {
      setState(() => _confirmError = 'Les mots de passe ne correspondent pas');
      hasError = true;
    }
    if (hasError) return;

    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const SignUpStep6Screen(isEmail: true),
  ),

);

Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const OtpScreen()),
);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEFBF7),
      body: Stack(
        children: [

          const SignupBubbles(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 45),

                  const HealioLogo(),

                  const SizedBox(height: 40),

                  // title
                  const Text(
                    'Pour la sécurité',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:      Colors.black87,
                      fontSize:   17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // subtitle
                  const Text(
                    'créez un mot de passe robuste',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:    Colors.black54,
                      fontSize: 12,
                      height:   1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // password field
                  AppTextField(
                    controller:  _passwordController,
                    hint:        'Créer un mot de passe',
                    obscureText: true,
                    errorText:   _passwordError,
                    onChanged:   (_) => setState(() => _passwordError = null),
                  ),

                  const SizedBox(height: 16),

                  // confirm password field
                  AppTextField(
                    controller:  _confirmController,
                    hint:        'Confirmer',
                    obscureText: true,
                    errorText:   _confirmError,
                    onChanged:   (_) => setState(() => _confirmError = null),
                  ),

                  const SizedBox(height: 160),

                  // suivant button
                  SizedBox(
                    width: 140,
                    child: AppButton(
                      label:        'Suivant',
                      borderRadius: 31,
                      onPressed:    _onSuivantePressed,
                    ),
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}