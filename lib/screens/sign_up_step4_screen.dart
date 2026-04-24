// screens/sign_up_step4_screen.dart
// Sign up step 4 — 1 emergency contact only (required)
// BACKEND TODO: include emergency_contacts in POST /api/auth/register

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';
import '../widgets/healio_logo.dart';
import '../widgets/signup_bubbles.dart';
import '../config/app_colors.dart';
import 'sign_up_step5_screen.dart';

class SignUpStep4Screen extends StatefulWidget {
  const SignUpStep4Screen({super.key});

  @override
  State<SignUpStep4Screen> createState() => _SignUpStep4ScreenState();
}

class _SignUpStep4ScreenState extends State<SignUpStep4Screen> {
  // Single contact — always required
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _nameError;
  String? _phoneError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSuivant() async {
    setState(() {
      _nameError  = _nameCtrl.text.trim().isEmpty  ? 'Requis' : null;
      _phoneError = _phoneCtrl.text.trim().isEmpty ? 'Requis' : null;
    });
    if (_nameError != null || _phoneError != null) return;

    // Persist as a single-item list (keeps API shape consistent)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'emergency_contacts',
      jsonEncode([
        {
          'name':  _nameCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
        }
      ]),
    );

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpStep5Screen()),
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
                  const Text(
                    'Pour la sécurité',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Saisissez votre contact d\'urgence',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 35),

                  // ── Single emergency contact ─────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact d\'urgence',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AppTextField(
                          controller: _nameCtrl,
                          hint: 'Nom complet',
                          errorText: _nameError,
                          onChanged: (_) =>
                              setState(() => _nameError = null),
                        ),
                        const SizedBox(height: 8),
                        AppTextField(
                          controller: _phoneCtrl,
                          hint: 'Numéro de téléphone',
                          keyboardType: TextInputType.phone,
                          errorText: _phoneError,
                          onChanged: (_) =>
                              setState(() => _phoneError = null),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),
                  SizedBox(
                    width: 140,
                    child: AppButton(
                      label: 'Suivant',
                      borderRadius: 31,
                      onPressed: _onSuivant,
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