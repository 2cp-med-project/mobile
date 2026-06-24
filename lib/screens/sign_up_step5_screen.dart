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
import 'formule_screen.dart';
import '../services/auth_service.dart';


class SignUpStep5Screen extends StatefulWidget {
  const SignUpStep5Screen({super.key});
  @override
  State<SignUpStep5Screen> createState() => _SignUpStep5ScreenState();
}

class _SignUpStep5ScreenState extends State<SignUpStep5Screen> {
  final _pwCtrl      = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool    _pwVisible      = false; // ← eye toggle for password
  bool    _confirmVisible = false; // ← eye toggle for confirm
  String? _pwError;
  String? _confirmError;
 bool    _isLoading = false; // for showing a loading indicator during OTP request
  @override
  void dispose() {
    _pwCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

 Future<void> _onSuivant() async {
  setState(() {
    _pwError = Validators.password(_pwCtrl.text);
    _confirmError = Validators.confirmPassword(
      _confirmCtrl.text,
      _pwCtrl.text,
    );
  });

  if (_pwError != null || _confirmError != null) return;

  final prefs = await SharedPreferences.getInstance();

  await prefs.setString(
    '_temp_password',
    _pwCtrl.text,
  );

  setState(() => _isLoading = true);

  final registerError = await AuthService.register();

  if (!mounted) return;

  setState(() => _isLoading = false);

  if (registerError != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(registerError)),
    );
    return;
  }

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => const FormuleScreen(),
    ),
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
                    'Créez un mot de passe robuste',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Password field with eye toggle ──────────────────────
                  AppTextField(
                    controller: _pwCtrl,
                    hint: 'Créer un mot de passe',
                    obscureText: !_pwVisible,
                    errorText: _pwError,
                    onChanged: (_) => setState(() => _pwError = null),
                    suffixIcon: GestureDetector(
                      onTap: () =>
                          setState(() => _pwVisible = !_pwVisible),
                      child: Icon(
                        _pwVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.black38,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Confirm field with eye toggle ───────────────────────
                  AppTextField(
                    controller: _confirmCtrl,
                    hint: 'Confirmer',
                    obscureText: !_confirmVisible,
                    errorText: _confirmError,
                    onChanged: (_) => setState(() => _confirmError = null),
                    suffixIcon: GestureDetector(
                      onTap: () =>
                          setState(() => _confirmVisible = !_confirmVisible),
                      child: Icon(
                        _confirmVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.black38,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 160),

                  SizedBox(
                    width: 140,
                    child: AppButton(
                      label: 'Suivant',
                      isLoading: _isLoading,
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