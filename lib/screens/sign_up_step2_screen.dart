// screens/sign_up_step2_screen.dart
// Sign up step 2 — date de naissance, lieu, sexe
// BACKEND TODO: include these fields in final POST /api/auth/register payload

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';
import '../widgets/healio_logo.dart';
import '../widgets/signup_bubbles.dart';
import 'sign_up_step3_screen.dart';
import '../config/validators.dart';

class SignUpStep2Screen extends StatefulWidget {
  const SignUpStep2Screen({super.key});

  @override
  State<SignUpStep2Screen> createState() => _SignUpStep2ScreenState();
}

class _SignUpStep2ScreenState extends State<SignUpStep2Screen> {
  final _jourController  = TextEditingController();
  final _moisController  = TextEditingController();
  final _anneeController = TextEditingController();
  final _lieuController  = TextEditingController();
  final _sexeController  = TextEditingController();

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

  void _onSuivantePressed() async {
    setState(() {
      _jourError  = null;
      _moisError  = null;
      _anneeError = null;
      _lieuError  = null;
      _sexeError  = null;
    });

    setState(() => _jourError  = Validators.day(_jourController.text));
    setState(() => _moisError  = Validators.month(_moisController.text));
    setState(() => _anneeError = Validators.year(_anneeController.text));
    setState(() => _lieuError  = Validators.required(_lieuController.text));
    setState(() => _sexeError  = Validators.required(_sexeController.text));

    if (_jourError != null || _moisError != null || _anneeError != null ||
        _lieuError != null || _sexeError != null) return;

    // ── Persist step 2 data ───────────────────────────────────────────────
    final prefs = await SharedPreferences.getInstance();
    // Format: "06 / 10 / 2000" — readable in profile screen
    final dateFormatted =
        '${_jourController.text.trim().padLeft(2, '0')} / '
        '${_moisController.text.trim().padLeft(2, '0')} / '
        '${_anneeController.text.trim()}';
    await prefs.setString('date_naissance', dateFormatted);
    await prefs.setString('lieu_naissance', _lieuController.text.trim());
    await prefs.setString('genre',          _sexeController.text.trim());
    // ─────────────────────────────────────────────────────────────────────

    if (!mounted) return;
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
          const SignupBubbles(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 45),
                  const Center(child: HealioLogo()),
                  const SizedBox(height: 60),
                  const Center(
                    child: Text(
                      'Informations générales',
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 17,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'Veuillez indiquer votre date et lieu\n de naissance ainsi que votre genre.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black54, fontSize: 12, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
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
                      Expanded(
                        child: AppTextField(
                          controller: _anneeController,
                          hint: 'Année',
                          keyboardType: TextInputType.number,
                          errorText: _anneeError,
                          onChanged: (_) =>
                              setState(() => _anneeError = null),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _lieuController,
                    hint: 'Lieu de naissance',
                    errorText: _lieuError,
                    onChanged: (_) => setState(() => _lieuError = null),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _sexeController,
                    hint: 'Sexe',
                    errorText: _sexeError,
                    onChanged: (_) => setState(() => _sexeError = null),
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