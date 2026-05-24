// screens/otp_screen.dart
// Phone‑only OTP verification. No email/phone toggle.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  String? _otpError;
  bool _isLoading = false;
  String? _phoneNumber;

  @override
  void initState() {
    super.initState();
    _loadPhoneNumber();
  }

  Future<void> _loadPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('phone');
    setState(() {
      _phoneNumber = phone;
    });
    if (phone == null || phone.isEmpty) {
      setState(() {
        _otpError = 'Numéro de téléphone introuvable. Veuillez recommencer.';
      });
    }
  }

  void _onDigitChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() => _otpError = null);
  }

  void _onResendPressed() async {
    if (_phoneNumber == null || !mounted) return;
    final error = await AuthService.requestOtp(_phoneNumber!, false);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nouveau code envoyé')),
      );
    }
  }

  void _onSuivantePressed() async {
    if (_phoneNumber == null) {
      setState(() => _otpError = 'Numéro non chargé. Réessayez.');
      return;
    }

    final code = _controllers.map((c) => c.text).join();
    if (code.length != 6) {
      setState(() => _otpError = 'Entrez le code complet (6 chiffres)');
      return;
    }

    setState(() {
      _isLoading = true;
      _otpError = null;
    });

    try {
      final verifyError = await AuthService.verifyOtp(code, _phoneNumber!);
      if (verifyError != null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _otpError = verifyError;
          });
        }
        return;
      }

      final registerError = await AuthService.register();

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (registerError == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FormuleScreen()),
        );
      } else {
        setState(() => _otpError = registerError);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _otpError = 'Erreur serveur';
        });
      }
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
                  const Text(
                    'Saisissez le code reçu par téléphone',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 36),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, _buildOtpBox),
                  ),
                  if (_otpError != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _otpError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: _onResendPressed,
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

  Widget _buildOtpBox(int index) {
    return Container(
      width: 45,        // smaller width to fit 6 boxes
      height: 52,
      margin: const EdgeInsets.symmetric(horizontal: 4),
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