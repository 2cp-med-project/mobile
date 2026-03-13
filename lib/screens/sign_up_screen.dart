// screens/sign_up_screen.dart
// Sign up page — step 1: Nom + Prénom

import 'package:flutter/material.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';
import '../widgets/healio_logo.dart';
import '../widgets/signup_bubbles.dart';
import '../config/app_colors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();

  String? _nomError;
  String? _prenomError;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    super.dispose();
  }

  void _onSuivantePressed() {
    setState(() {
      _nomError = null;
      _prenomError = null;
    });

    bool hasError = false;
    if (_nomController.text.trim().isEmpty) {
      setState(() => _nomError = 'Entrez votre nom');
      hasError = true;
    }
    if (_prenomController.text.trim().isEmpty) {
      setState(() => _prenomError = 'Entrez votre prénom');
      hasError = true;
    }
    if (hasError) return;

    // TODO: navigate to next sign up step
    // Navigator.pushNamed(context, AppRoutes.signUpStep2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEFBF7),
      body: Stack(
        children: [
          // background blobs — imported from widgets/signup_bubbles.dart
          const SignupBubbles(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 45),

                  // logo — same component as sign in
                  const Center(child: HealioLogo()),

                  const SizedBox(height: 80),

                  // title
                  const Center(
                    child: Text(
                      'Créer un compte healio',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // subtitle
                  const Center(
                    child: Text(
                      'Entrez votre nom :',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ),

                  const SizedBox(height: 72),

                  // nom field
                  AppTextField(
                    controller: _nomController,
                    hint: 'Nom',
                    errorText: _nomError,
                    onChanged: (_) => setState(() => _nomError = null),
                  ),

                  const SizedBox(height: 24),

                  // prénom field
                  AppTextField(
                    controller: _prenomController,
                    hint: 'Prénom',
                    errorText: _prenomError,
                    onChanged: (_) => setState(() => _prenomError = null),
                  ),

                  const SizedBox(height: 150),

                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 140,
                      child: AppButton(
                        label: 'Suivante',
                        borderRadius: 31, 
                        onPressed: _onSuivantePressed,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
