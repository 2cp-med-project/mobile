// Logic required in the fields (case of mdp<8, phone/email invalid, empty fields...)

import 'package:flutter/material.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';
import '../widgets/healio_logo.dart';
import '../widgets/signup_bubbles.dart';
import '../config/app_colors.dart';
import 'sign_up_step2_screen.dart';

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

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpStep2Screen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEFBF7),
      body: Stack(
        children: [
          // background
          const SignupBubbles(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 45),

                  // logo
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

                  const SizedBox(height: 130),

                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 140,
                      child: AppButton(
                        label: 'Suivant',
                        borderRadius: 31,
                        onPressed: _onSuivantePressed,
                      ),
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
