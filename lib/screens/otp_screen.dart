// screens/otp_screen.dart
// FINAL FIX: OTP screen now triggers REGISTER properly

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/app_button.dart';
import '../widgets/healio_logo.dart';
import '../widgets/signup_bubbles.dart';
import '../config/app_colors.dart';
import '../services/auth_service.dart';
import 'formule_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  bool _isEmail = true;

  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());

  final List<FocusNode> _focusNodes =
      List.generate(4, (_) => FocusNode());

  String? _otpError;
  bool _isLoading = false;

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _onDigitChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() => _otpError = null);
  }

  void _toggleMethod() {
    setState(() {
      _isEmail = !_isEmail;
      for (final c in _controllers) c.clear();
      _otpError = null;
    });
  }

  void _onResendPressed() {
    print("📨 RESEND OTP CLICKED");
  }

  // 🔥 MAIN FIXED FUNCTION
  void _onSuivantePressed() async {
    print("\n════════ OTP SUBMIT ════════");

    final code = _controllers.map((c) => c.text).join();

    print("🔐 OTP CODE: $code");

    if (code.length < 4) {
      setState(() => _otpError = 'Entrez le code complet');
      return;
    }

    setState(() => _isLoading = true);

    try {
      print("🚀 START REGISTER FROM OTP SCREEN");

      final result = await AuthService.register();

      print("📡 REGISTER RESULT: $result");

      setState(() => _isLoading = false);

      if (result == null) {
        print("✅ USER CREATED SUCCESSFULLY");

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FormuleScreen()),
        );
      } else {
        print("❌ REGISTER FAILED: $result");
        setState(() => _otpError = result);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print("🔥 EXCEPTION: $e");
      setState(() => _otpError = "Erreur serveur");
    }
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
                children: [
                  const SizedBox(height: 45),
                  const HealioLogo(),
                  const SizedBox(height: 50),

                  Text(
                    'Pour vérification',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    _isEmail
                        ? 'Saisissez le code reçu par e-mail'
                        : 'Saisissez le code reçu par téléphone',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),

                  const SizedBox(height: 36),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, _buildOtpBox),
                  ),

                  if (_otpError != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _otpError!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ],

                  const SizedBox(height: 30),

                  GestureDetector(
                    onTap: _onResendPressed,
                    child: const Text("Renvoyer"),
                  ),

                  GestureDetector(
                    onTap: _toggleMethod,
                    child: Text(
                      _isEmail
                          ? "Utiliser téléphone"
                          : "Utiliser e-mail",
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),

                  const SizedBox(height: 120),

                  SizedBox(
                    width: 140,
                    child: AppButton(
                      label: "Suivant",
                      isLoading: _isLoading,
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

  Widget _buildOtpBox(int index) {
    return Container(
      width: 52,
      height: 52,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        onChanged: (v) => _onDigitChanged(v, index),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(counterText: ''),
      ),
    );
  }
}