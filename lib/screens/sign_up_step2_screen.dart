// Logic required in the fields (case of mdp<8, phone/email invalid, empty fields...)

import 'package:flutter/material.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';
import '../widgets/healio_logo.dart';
import '../widgets/signup_bubbles.dart';
import '../config/app_colors.dart';
import 'sign_up_step3_screen.dart';


class SignUpStep2Screen extends StatefulWidget {
  const SignUpStep2Screen({super.key});

  @override
  State<SignUpStep2Screen> createState() => _SignUpStep2ScreenState();
}

class _SignUpStep2ScreenState extends State<SignUpStep2Screen> {
  final _jourController = TextEditingController();
  final _moisController = TextEditingController();
  final _anneeController = TextEditingController();
  final _lieuController = TextEditingController();
  final _sexeController = TextEditingController();

  String? _jourError;
  String? _moisError;
  String? _anneeError;
  String? _lieuError;
  String? _sexeError;

  @override
  void dispose() {
    _jourController.dispose();
    _moisController.dispose();
    _anneeController.dispose();
    _lieuController.dispose();
    _sexeController.dispose();
    super.dispose();
  }

  void _onSuivantePressed() {
    setState(() {
      _jourError = null;
      _moisError = null;
      _anneeError = null;
      _lieuError = null;
      _sexeError = null;
    });

    bool hasError = false;
    if (_jourController.text.trim().isEmpty) {
      setState(() => _jourError = 'Requis');
      hasError = true;
    }
    if (_moisController.text.trim().isEmpty) {
      setState(() => _moisError = 'Requis');
      hasError = true;
    }
    if (_anneeController.text.trim().isEmpty) {
      setState(() => _anneeError = 'Requis');
      hasError = true;
    }
    if (_lieuController.text.trim().isEmpty) {
      setState(() => _lieuError = 'Requis');
      hasError = true;
    }
    if (_sexeController.text.trim().isEmpty) {
      setState(() => _sexeError = 'Requis');
      hasError = true;
    }
    if (hasError) return;

    Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const SignUpStep3Screen()),
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 45),

                  // logo
                  const Center(child: HealioLogo()),

                  const SizedBox(height: 60),

                  // title
                  const Center(
                    child: Text(
                      'Informations générales',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // subtitle
                  const Center(
                    child: Text(
                      'Veuillez indiquer votre date et lieu\n de naissance ainsi que votre genre.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      // jour
                      Expanded(
                        child: AppTextField(
                          controller: _jourController,
                          hint: 'Jour',
                          keyboardType: TextInputType.number,
                          errorText: _jourError,
                          onChanged: (_) => setState(() => _jourError = null),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // mois
                      Expanded(
                        child: AppTextField(
                          controller: _moisController,
                          hint: 'Mois',
                          keyboardType: TextInputType.number,
                          errorText: _moisError,
                          onChanged: (_) => setState(() => _moisError = null),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // année
                      Expanded(
                        child: AppTextField(
                          controller: _anneeController,
                          hint: 'Année',
                          keyboardType: TextInputType.number,
                          errorText: _anneeError,
                          onChanged: (_) => setState(() => _anneeError = null),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // lieu de naissance
                  AppTextField(
                    controller: _lieuController,
                    hint: 'Lieu de naissance',
                    errorText: _lieuError,
                    onChanged: (_) => setState(() => _lieuError = null),
                  ),

                  const SizedBox(height: 16),

                  // sexe
                  AppTextField(
                    controller: _sexeController,
                    hint: 'Sexe',
                    errorText: _sexeError,
                    onChanged: (_) => setState(() => _sexeError = null),
                  ),

                  const SizedBox(height: 130),

                  // suivant button
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
