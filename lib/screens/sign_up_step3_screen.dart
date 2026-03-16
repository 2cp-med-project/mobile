// Logic required in the fields (case of mdp<8, phone/email invalid, empty fields...)

import 'package:flutter/material.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';
import '../widgets/healio_logo.dart';
import '../widgets/signup_bubbles.dart';
import 'sign_up_step4_screen.dart';
import '../config/validators.dart';

class SignUpStep3Screen extends StatefulWidget {
  const SignUpStep3Screen({super.key});

  @override
  State<SignUpStep3Screen> createState() => _SignUpStep3ScreenState();
}

class _SignUpStep3ScreenState extends State<SignUpStep3Screen> {
  final _adresseController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  String? _adresseError;
  String? _phoneError;
  String? _emailError;

  @override
  void dispose() {
    _adresseController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onSuivantePressed() {
    setState(() {
      _adresseError = null;
      _phoneError = null;
      _emailError = null;
    });

    setState(
      () => _adresseError = Validators.required(_adresseController.text),
    );
    setState(() => _phoneError = Validators.phone(_phoneController.text));
    setState(() => _emailError = Validators.email(_emailController.text));

      if (_adresseError != null || _phoneError != null || _emailError != null) {
        return;
      }
      
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpStep4Screen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEFBF7),
      body: Stack(
        children: [
          // background blobs
          const SignupBubbles(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 45),

                  // logo
                  const HealioLogo(),

                  const SizedBox(height: 60),

                  // title
                  const Text(
                    'Informations générales',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // subtitle
                  const Text(
                    'Veuillez saisir votre adresse, votre numéro\nde téléphone et votre adresse e-mail.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 35),

                  // adress field
                  AppTextField(
                    controller: _adresseController,
                    hint: 'Adresse',
                    errorText: _adresseError,
                    onChanged: (_) => setState(() => _adresseError = null),
                  ),

                  const SizedBox(height: 16),

                  // phone field
                  AppTextField(
                    controller: _phoneController,
                    hint: 'Numéro de téléphone',
                    keyboardType: TextInputType.phone,
                    errorText: _phoneError,
                    onChanged: (_) => setState(() => _phoneError = null),
                  ),

                  const SizedBox(height: 16),

                  // email field
                  AppTextField(
                    controller: _emailController,
                    hint: 'E-mail',
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailError,
                    onChanged: (_) => setState(() => _emailError = null),
                  ),

                  const SizedBox(height: 130),

                  SizedBox(
                    width: 140,
                    child: AppButton(
                      label: 'Suivant',
                      borderRadius: 31,
                      onPressed: _onSuivantePressed,
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
