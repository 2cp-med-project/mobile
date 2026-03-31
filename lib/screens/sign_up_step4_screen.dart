// screens/sign_up_step4_screen.dart
// Sign up step 4 — ID + contacts d'urgence (max 4, dynamic via + button)
// BACKEND TODO: include patient_id and emergency_contacts in POST /api/auth/register

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';
import '../widgets/healio_logo.dart';
import '../widgets/signup_bubbles.dart';
import '../config/app_colors.dart';
import 'sign_up_step5_screen.dart';
import '../config/validators.dart';

class SignUpStep4Screen extends StatefulWidget {
  const SignUpStep4Screen({super.key});

  @override
  State<SignUpStep4Screen> createState() => _SignUpStep4ScreenState();
}

class _SignUpStep4ScreenState extends State<SignUpStep4Screen> {
  final _idController = TextEditingController();
  String? _idError;

  // Each emergency contact has a name + phone field pair
  final List<TextEditingController> _nameControllers  = [TextEditingController()];
  final List<TextEditingController> _phoneControllers = [TextEditingController()];
  final List<String?> _nameErrors  = [null];
  final List<String?> _phoneErrors = [null];

  @override
  void dispose() {
    _idController.dispose();
    for (final c in _nameControllers)  c.dispose();
    for (final c in _phoneControllers) c.dispose();
    super.dispose();
  }

  void _addEmergencyField() {
    if (_nameControllers.length >= 4) return;
    setState(() {
      _nameControllers.add(TextEditingController());
      _phoneControllers.add(TextEditingController());
      _nameErrors.add(null);
      _phoneErrors.add(null);
    });
  }

  void _onSuivantePressed() async {
    setState(() {
      _idError = null;
      for (int i = 0; i < _nameErrors.length; i++) {
        _nameErrors[i]  = null;
        _phoneErrors[i] = null;
      }
    });

    bool hasError = false;

    setState(() => _idError = Validators.required(_idController.text));
    if (_idError != null) hasError = true;

    for (int i = 0; i < _nameControllers.length; i++) {
      if (_nameControllers[i].text.trim().isEmpty) {
        setState(() => _nameErrors[i] = 'Requis');
        hasError = true;
      }
      if (_phoneControllers[i].text.trim().isEmpty) {
        setState(() => _phoneErrors[i] = 'Requis');
        hasError = true;
      }
    }

    if (hasError) return;

    // ── Persist step 4 data ───────────────────────────────────────────────
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('patient_id', _idController.text.trim());

    // Store contacts as JSON list: [{name, phone}, ...]
    final contacts = List.generate(_nameControllers.length, (i) => {
      'name':  _nameControllers[i].text.trim(),
      'phone': _phoneControllers[i].text.trim(),
    });
    await prefs.setString('emergency_contacts', jsonEncode(contacts));
    // ─────────────────────────────────────────────────────────────────────

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
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Saisissez votre ID et vos contacts\nd\'urgence',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black54, fontSize: 12, height: 1.5),
                  ),
                  const SizedBox(height: 35),

                  // ID field
                  AppTextField(
                    controller: _idController,
                    hint: 'ID',
                    errorText: _idError,
                    onChanged: (_) => setState(() => _idError = null),
                  ),

                  const SizedBox(height: 20),

                  // Emergency contact pairs (name + phone)
                  ...List.generate(_nameControllers.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Contact label
                          Text(
                            'Contact d\'urgence ${i + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textGrey,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Name field
                          AppTextField(
                            controller: _nameControllers[i],
                            hint: 'Nom complet',
                            errorText: _nameErrors[i],
                            onChanged: (_) =>
                                setState(() => _nameErrors[i] = null),
                          ),
                          const SizedBox(height: 8),
                          // Phone row + add button on last
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: AppTextField(
                                  controller: _phoneControllers[i],
                                  hint: 'Numéro de téléphone',
                                  keyboardType: TextInputType.phone,
                                  errorText: _phoneErrors[i],
                                  onChanged: (_) =>
                                      setState(() => _phoneErrors[i] = null),
                                ),
                              ),
                              // + button only on last row and under limit
                              if (i == _nameControllers.length - 1 &&
                                  _nameControllers.length < 4) ...[
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: _addEmergencyField,
                                  child: Container(
                                    height: 50,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: AppColors.border, width: 1.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.add,
                                        color: AppColors.primary, size: 20),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  }),

                  if (_nameControllers.length == 4)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Maximum 4 contacts atteint',
                        style: TextStyle(
                            color: AppColors.textGrey, fontSize: 11),
                      ),
                    ),

                  const SizedBox(height: 60),

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