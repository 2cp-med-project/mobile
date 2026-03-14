// screens/otp_screen.dart
// OTP verification — 4 digit code boxes + toggle between email and phone

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/app_button.dart';
import '../widgets/healio_logo.dart';
import '../widgets/signup_bubbles.dart';
import '../config/app_colors.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // true = sent via email, false = sent via phone
  bool _isEmail = true;

  // 4 controllers + focus nodes for each OTP box
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

  // auto jump to next box when a digit is typed
  void _onDigitChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() => _otpError = null);
  }

  // toggle between email and phone — UI changes + TODO: call backend
  void _toggleMethod() {
    setState(() {
      _isEmail = !_isEmail;
      for (final c in _controllers) c.clear();
      _otpError = null;
    });
    // TODO: call AuthService.resendOtp(method: _isEmail ? 'email' : 'phone');
  }

  void _onResendPressed() {
    // TODO: call AuthService.resendOtp(method: _isEmail ? 'email' : 'phone');
  }

  void _onSuivantePressed() {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 4) {
      setState(() => _otpError = 'Entrez le code complet');
      return;
    }
    // TODO: await AuthService.verifyOtp(code: code);
    // TODO: Navigator.pushReplacementNamed(context, AppRoutes.home);
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

                  // subtitle changes based on toggle
                  Text(
                    _isEmail
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
                    children: List.generate(4, (i) => _buildOtpBox(i)),
                  ),

                  // error message
                  if (_otpError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _otpError!,
                      style: TextStyle(color: AppColors.error, fontSize: 11),
                    ),
                  ],

                  const SizedBox(height: 35),

                  // renvoyer
                  GestureDetector(
                    onTap: _onResendPressed,
                    child: const Text(
                      'Renvoyer',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // toggle link — changes text and method
                  GestureDetector(
                    onTap: _toggleMethod,
                    child: Text(
                      _isEmail
                          ? 'Utilisez votre numéro de téléphone\npour recevoir le code'
                          : 'Utilisez e-mail pour recevoir le code',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:      AppColors.primary,
                        fontSize:   12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 150),

                  // suivante button
                  SizedBox(
                    width: 140,
                    child: AppButton(
                      label:        'Suivant',
                      isLoading:    _isLoading,
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

  // single OTP digit box
  Widget _buildOtpBox(int index) {
    return Container(
      width:  52,
      height: 52,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: TextField(
        controller:  _controllers[index],
        focusNode:   _focusNodes[index],
        onChanged:   (v) => _onDigitChanged(v, index),
        keyboardType: TextInputType.number,
        textAlign:    TextAlign.center,
        maxLength:    1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          fontSize:   18,
          fontWeight: FontWeight.w700,
          color:      AppColors.primary,
        ),
        decoration: InputDecoration(
          counterText: '',   // hides the "0/1" counter
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: _otpError != null ? AppColors.error : AppColors.border,
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}