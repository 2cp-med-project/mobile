// screens/sign_up_step6_screen.dart
// FIXED: now actually triggers backend signup instead of only navigating

import 'package:flutter/material.dart';
import '../widgets/app_button.dart';
import '../widgets/healio_logo.dart';
import '../widgets/signup_bubbles.dart';
import '../config/app_colors.dart';
import '../services/auth_service.dart';
import 'formule_screen.dart';

class SignUpStep6Screen extends StatefulWidget {
  final bool isEmail;

  const SignUpStep6Screen({super.key, this.isEmail = true});

  @override
  State<SignUpStep6Screen> createState() => _SignUpStep6ScreenState();
}

class _SignUpStep6ScreenState extends State<SignUpStep6Screen> {
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

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() => _otpError = null);
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onSuivantePressed() async {


    if (_code.length < 4) {
      setState(() => _otpError = 'Entrez le code complet');
      return;
    }

    setState(() => _isLoading = true);

    try {

      final result = await AuthService.register();


      setState(() => _isLoading = false);

      if (result == null) {

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FormuleScreen()),
        );
      } else {
        setState(() => _otpError = result);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      setState(() => _otpError = "Erreur serveur");
    }
  }

  void _onResend() {
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
                    widget.isEmail
                        ? 'Code reçu par e-mail'
                        : 'Code reçu par téléphone',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),

                  const SizedBox(height: 36),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) {
                      return Container(
                        width: 56,
                        height: 52,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        child: TextField(
                          controller: _controllers[i],
                          focusNode: _focusNodes[i],
                          onChanged: (v) => _onChanged(v, i),
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            counterText: '',
                          ),
                        ),
                      );
                    }),
                  ),

                  if (_otpError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _otpError!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ],

                  const SizedBox(height: 40),

                  GestureDetector(
                    onTap: _onResend,
                    child: const Text("Renvoyer"),
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
}