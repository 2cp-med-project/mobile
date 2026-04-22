// screens/sign_up_step5_screen.dart — INTEGRATED
// Saves password temporarily; step6 will call AuthService.register()

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';
import '../widgets/healio_logo.dart';
import '../widgets/signup_bubbles.dart';
import 'sign_up_step6_screen.dart';
import '../config/validators.dart';

class SignUpStep5Screen extends StatefulWidget {
  const SignUpStep5Screen({super.key});
  @override
  State<SignUpStep5Screen> createState() => _SignUpStep5ScreenState();
}

class _SignUpStep5ScreenState extends State<SignUpStep5Screen> {
  final _pwCtrl      = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _pwError;
  String? _confirmError;

  @override
  void dispose() { _pwCtrl.dispose(); _confirmCtrl.dispose(); super.dispose(); }

  Future<void> _onSuivant() async {
    setState(() {
      _pwError      = Validators.password(_pwCtrl.text);
      _confirmError = Validators.confirmPassword(_confirmCtrl.text, _pwCtrl.text);
    });
    if (_pwError != null || _confirmError != null) return;

    // Save temp password — AuthService.register() will read & delete it
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('_temp_password', _pwCtrl.text);

    if (!mounted) return;
    // Navigate to OTP step — registration happens inside step 6
    Navigator.push(context,
        MaterialPageRoute(
            builder: (_) => const SignUpStep6Screen(isEmail: false)));
    // isEmail: false → OTP sent via phone (your API uses phone for OTP)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEFBF7),
      body: Stack(children: [
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
                const Text('Pour la sécurité',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 17,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                const Text('Créez un mot de passe robuste',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black54, fontSize: 12, height: 1.5)),
                const SizedBox(height: 40),
                AppTextField(
                  controller: _pwCtrl,
                  hint: 'Créer un mot de passe',
                  obscureText: true,
                  errorText: _pwError,
                  onChanged: (_) => setState(() => _pwError = null),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _confirmCtrl,
                  hint: 'Confirmer',
                  obscureText: true,
                  errorText: _confirmError,
                  onChanged: (_) => setState(() => _confirmError = null),
                ),
                const SizedBox(height: 160),
                SizedBox(
                  width: 140,
                  child: AppButton(
                      label: 'Suivant',
                      borderRadius: 31,
                      onPressed: _onSuivant),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}