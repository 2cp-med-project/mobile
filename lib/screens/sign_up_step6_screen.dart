// screens/sign_up_step6_screen.dart
// Sign up step 6 — OTP verification (4 digit code via email or phone)

import 'package:flutter/material.dart';
import '../widgets/app_button.dart';
import '../widgets/healio_logo.dart';
import '../widgets/signup_bubbles.dart';
import '../config/app_colors.dart';

class SignUpStep6Screen extends StatefulWidget {
  // pass true for email verification, false for phone verification
  final bool isEmail;
  const SignUpStep6Screen({super.key, this.isEmail = true});

  @override
  State<SignUpStep6Screen> createState() => _SignUpStep6ScreenState();
}

class _SignUpStep6ScreenState extends State<SignUpStep6Screen> {
  // 4 controllers for the 4 OTP boxes
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode>             _focusNodes  = List.generate(4, (_) => FocusNode());

  String? _otpError;

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes)  f.dispose();
    super.dispose();
  }

  // auto jump to next box when a digit is entered
  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() => _otpError = null);
  }

  String get _fullCode => _controllers.map((c) => c.text).join();

  void _onSuivantePressed() {
    if (_fullCode.length < 4) {
      setState(() => _otpError = 'Entrez le code complet');
      return;
    }
    // TODO: verify OTP with backend
    // await AuthService.verifyOTP(code: _fullCode);
    // Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  void _onResend() {
    // TODO: resend OTP
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

                  const SizedBox(height: 50),

                  // title
                  Text(
                    'Pour vérification',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:      AppColors.primary,
                      fontSize:   18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // subtitle — changes based on email or phone
                  Text(
                    widget.isEmail
                        ? 'Saisissez le code que vous avez\nreçu par e-mail :'
                        : 'Saisissez le code que vous avez reçu\ndans le champ Numéro de téléphone',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color:    Colors.black54,
                      fontSize: 12,
                      height:   1.5,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // 4 OTP boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) {
                      return Container(
                        width:  56,
                        height: 52,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        child: TextField(
                          controller:   _controllers[i],
                          focusNode:    _focusNodes[i],
                          onChanged:    (v) => _onChanged(v, i),
                          keyboardType: TextInputType.number,
                          maxLength:    1,
                          textAlign:    TextAlign.center,
                          style: TextStyle(
                            fontSize:   18,
                            fontWeight: FontWeight.w600,
                            color:      AppColors.primary,
                          ),
                          decoration: InputDecoration(
                            counterText: '',   
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: _otpError != null ? AppColors.error : AppColors.border,
                                width: 1.2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  // error message
                  if (_otpError != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _otpError!,
                      style: TextStyle(color: AppColors.error, fontSize: 11),
                    ),
                  ],

                  const SizedBox(height: 35),

                  // resend section
                  const Text(
                    'Renvoyer',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _onResend,
                    child: Text(
                      widget.isEmail
                          ? 'Utilisez votre numéro de téléphone\npour recevoir le code'
                          : 'Utilisez e-mail pour recevoir le code',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:    AppColors.primary,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 150),

                  // suivant button 
                  SizedBox(
                    width: 140,
                    child: AppButton(
                      label:        'Suivant',
                      borderRadius: 31,
                      onPressed:    _onSuivantePressed,
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