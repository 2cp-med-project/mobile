// screens/forgot_password_screen.dart
// Forgot password flow:
// Step 1 — enter phone or email (toggle between them)
// Step 2 — OTP verification (4 boxes)
// Step 3 — redirects to WelcomeScreen

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/healio_logo.dart';
import '../widgets/signup_bubbles.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';
import '../config/app_colors.dart';
import '../config/validators.dart';
import 'welcome_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int  _step    = 1;
  bool _isPhone = true;

  final _inputController = TextEditingController();
  String? _inputError;

  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(4, (_) => FocusNode());
  String? _otpError;

  @override
  void dispose() {
    _inputController.dispose();
    for (final c in _otpControllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _toggleMethod() {
    setState(() {
      _isPhone = !_isPhone;
      _inputController.clear();
      _inputError = null;
    });
  }

  void _onSuivanteStep1() {
    setState(() {
      _inputError = _isPhone
          ? Validators.phone(_inputController.text)
          : Validators.email(_inputController.text);
    });
    if (_inputError != null) return;
    // TODO: await AuthService.sendResetCode(input: _inputController.text);
    setState(() => _step = 2);
  }

  void _onSuivanteStep2() {
    final code = _otpControllers.map((c) => c.text).join();
    if (code.length < 4) {
      setState(() => _otpError = 'Entrez le code complet');
      return;
    }
    // TODO: await AuthService.verifyResetCode(code: code);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 3) _focusNodes[index + 1].requestFocus();
    if (value.isEmpty  && index > 0)    _focusNodes[index - 1].requestFocus();
    setState(() => _otpError = null);
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
                  const SizedBox(height: 65),
                  const HealioLogo(),
                  const SizedBox(height: 64),
                  _step == 1 ? _buildStep1() : _buildStep2(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 1 
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        const Text(
          'Trouvez votre compte HEALIO',
          textAlign: TextAlign.center,
          style: TextStyle(
            color:      Colors.black87,
            fontSize:   17,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          _isPhone ? 'Entrez votre numéro de téléphone' : 'Entrez votre e-mail',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),

        const SizedBox(height: 28),

        AppTextField(
          controller:   _inputController,
          hint:         _isPhone ? 'Numéro de téléphone' : 'E-mail',
          keyboardType: _isPhone ? TextInputType.phone : TextInputType.emailAddress,
          errorText:    _inputError,
          onChanged:    (_) => setState(() => _inputError = null),
        ),

        const SizedBox(height: 26),

        GestureDetector(
          onTap: _toggleMethod,
          child: Text(
            _isPhone ? 'Utilisez votre e-mail' : 'Utilisez votre numéro de téléphone',
            textAlign: TextAlign.center,
            style: TextStyle(
              color:      AppColors.primary,
              fontSize:   12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(height: 170),

        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 140,
            child: AppButton(
              label:        'Suivant',
              borderRadius: 31,
              onPressed:    _onSuivanteStep1,
            ),
          ),
        ),
      ],
    );
  }

  // ── Step 2
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        Text(
          'Pour vérification',
          textAlign: TextAlign.center,
          style: TextStyle(
            color:      AppColors.primary,
            fontSize:   18,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Saisissez le code que vous avez reçu',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54, fontSize: 12),
        ),

        const SizedBox(height: 36),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (i) => _buildOtpBox(i)),
        ),

        if (_otpError != null) ...[
          const SizedBox(height: 8),
          Text(
            _otpError!,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.error, fontSize: 11),
          ),
        ],

        const SizedBox(height: 20),

        GestureDetector(
          onTap: () {
            // TODO: AuthService.resendResetCode();
          },
          child: const Text(
            'Renvoyer',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ),

        const SizedBox(height: 170),

        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 140,
            child: AppButton(
              label:        'Suivant',
              borderRadius: 31,
              onPressed:    _onSuivanteStep2,
            ),
          ),
        ),
      ],
    );
  }

  // single OTP digit box
  Widget _buildOtpBox(int index) {
    return Container(
      width:  52,
      height: 52,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: TextField(
        controller:      _otpControllers[index],
        focusNode:       _focusNodes[index],
        onChanged:       (v) => _onOtpChanged(v, index),
        keyboardType:    TextInputType.number,
        textAlign:       TextAlign.center,
        maxLength:       1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          fontSize:   18,
          fontWeight: FontWeight.w700,
          color:      AppColors.primary,
        ),
        decoration: InputDecoration(
          counterText:    '',
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