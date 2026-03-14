// screens/sign_up_step4_screen.dart
// Sign up step 4 — ID + contact d'urgence (max 5, dynamic via + button)

import 'package:flutter/material.dart';
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
  final _idController = TextEditingController();
  String? _idError;

  // starts with 1 emergency contact field, max 5
  final List<TextEditingController> _emergencyControllers = [
    TextEditingController(),
  ];
  final List<String?> _emergencyErrors = [null];

  @override
  void dispose() {
    _idController.dispose();
    for (final c in _emergencyControllers) c.dispose();
    super.dispose();
  }

  // add a new emergency contact field (max 5)
  void _addEmergencyField() {
    if (_emergencyControllers.length >= 5) return;
    setState(() {
      _emergencyControllers.add(TextEditingController());
      _emergencyErrors.add(null);
    });
  }

  void _onSuivantePressed() {
    setState(() {
      _idError = null;
      for (int i = 0; i < _emergencyErrors.length; i++) {
        _emergencyErrors[i] = null;
      }
    });

    bool hasError = false;
    if (_idController.text.trim().isEmpty) {
      setState(() => _idError = 'Requis');
      hasError = true;
    }
    for (int i = 0; i < _emergencyControllers.length; i++) {
      if (_emergencyControllers[i].text.trim().isEmpty) {
        setState(() => _emergencyErrors[i] = 'Requis');
        hasError = true;
      }
    }
    if (hasError) return;
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

                  // title
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

                  // subtitle
                  const Text(
                    'Saisissez votre ID et votre contact\nd\'urgence',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 35),

                  // ID field
                  AppTextField(
                    controller: _idController,
                    hint: 'ID',
                    errorText: _idError,
                    onChanged: (_) => setState(() => _idError = null),
                  ),

                  const SizedBox(height: 16),

                  // emergency contact fields
                  ...List.generate(_emergencyControllers.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // contact field
                          Expanded(
                            child: AppTextField(
                              controller: _emergencyControllers[i],
                              hint: 'Contact d\'urgence',
                              keyboardType: TextInputType.phone,
                              errorText: _emergencyErrors[i],
                              onChanged: (_) =>
                                  setState(() => _emergencyErrors[i] = null),
                            ),
                          ),

                          // + button
                          if (i == _emergencyControllers.length - 1 &&
                              _emergencyControllers.length < 4) ...[
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _addEmergencyField,
                              child: Container(
                                height: 50,
                                width: 40,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 1.2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),

                  // show max reached message
                  if (_emergencyControllers.length == 4)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Maximum 4 contacts atteint',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 11,
                        ),
                      ),
                    ),

                  const SizedBox(height: 160),

                  // suivant button
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
