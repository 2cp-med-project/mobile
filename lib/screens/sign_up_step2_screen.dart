// screens/sign_up_step2_screen.dart
// Sign up step 2 — date de naissance, lieu, sexe
// BACKEND TODO: include these fields in final POST /api/auth/register payload

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';
import '../widgets/healio_logo.dart';
import '../widgets/signup_bubbles.dart';
import '../config/app_colors.dart';
import 'sign_up_step3_screen.dart';
import '../config/validators.dart';

class SignUpStep2Screen extends StatefulWidget {
  const SignUpStep2Screen({super.key});

  @override
  State<SignUpStep2Screen> createState() => _SignUpStep2ScreenState();
}

class _SignUpStep2ScreenState extends State<SignUpStep2Screen> {
  // Date — kept as free text fields exactly as before
  final _jourController = TextEditingController();
  final _moisController = TextEditingController();
  final _anneeController = TextEditingController();
  final _lieuController = TextEditingController();

  // Gender — chosen from bottom sheet instead of typed
  String? _sexe;

  String? _jourError;
  String? _moisError;
  String? _anneeError;
  String? _lieuError;
  String? _sexeError;

  @override
  void dispose() {
    _jourController.dispose();
    _moisController.dispose();
    _anneeController.dispose();
    _lieuController.dispose();
    super.dispose();
  }

  // ── Gender picker (bottom sheet) ─────────────────────────────────────────
  void _pickGender() {
    final options = ['Homme', 'Femme'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Genre',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 14),
            ...options.map((opt) {
              final selected = _sexe == opt;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _sexe = opt;
                    _sexeError = null;
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : const Color(0xFFF4FBF8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? AppColors.primary : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        opt,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: selected ? AppColors.primary : Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      if (selected)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: 18,
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _onSuivantePressed() async {
    setState(() {
      _jourError = null;
      _moisError = null;
      _anneeError = null;
      _lieuError = null;
      _sexeError = null;
    });

    setState(() => _jourError = Validators.day(_jourController.text));
    setState(() => _moisError = Validators.month(_moisController.text));
    setState(() => _anneeError = Validators.year(_anneeController.text));
    setState(() => _lieuError = Validators.required(_lieuController.text));
    setState(() => _sexeError = _sexe == null ? 'Requis' : null);

    if (_jourError != null ||
        _moisError != null ||
        _anneeError != null ||
        _lieuError != null ||
        _sexeError != null)
      return;

    // ── Persist step 2 data 
    final prefs = await SharedPreferences.getInstance();
    final dateFormatted =
        '${_jourController.text.trim().padLeft(2, '0')} / '
        '${_moisController.text.trim().padLeft(2, '0')} / '
        '${_anneeController.text.trim()}';
    const uid = 'signup_temp';

    await prefs.setString('${uid}_date_naissance', dateFormatted);
    await prefs.setString('${uid}_lieu_naissance', _lieuController.text.trim());
    await prefs.setString('${uid}_genre', _sexe!);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpStep3Screen()),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 45),
                  const Center(child: HealioLogo()),
                  const SizedBox(height: 60),
                  const Center(
                    child: Text(
                      'Informations générales',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'Veuillez indiquer votre date et lieu\n de naissance ainsi que votre genre.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // ── Date fields — unchanged ──────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _jourController,
                          hint: 'Jour',
                          keyboardType: TextInputType.number,
                          errorText: _jourError,
                          onChanged: (_) => setState(() => _jourError = null),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppTextField(
                          controller: _moisController,
                          hint: 'Mois',
                          keyboardType: TextInputType.number,
                          errorText: _moisError,
                          onChanged: (_) => setState(() => _moisError = null),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppTextField(
                          controller: _anneeController,
                          hint: 'Année',
                          keyboardType: TextInputType.number,
                          errorText: _anneeError,
                          onChanged: (_) => setState(() => _anneeError = null),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Lieu de naissance — unchanged ────────────────────────
                  AppTextField(
                    controller: _lieuController,
                    hint: 'Lieu de naissance',
                    errorText: _lieuError,
                    onChanged: (_) => setState(() => _lieuError = null),
                  ),

                  const SizedBox(height: 16),

                  // ── Genre — taps to open bottom sheet ────────────────────
                  GestureDetector(
                    onTap: _pickGender,
                    child: AbsorbPointer(
                      child: AppTextField(
                        controller: TextEditingController(text: _sexe ?? ''),
                        hint: 'Sexe',
                        errorText: _sexeError,
                        suffixIcon: const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        onChanged: (_) {},
                      ),
                    ),
                  ),

                  const SizedBox(height: 130),
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 140,
                      child: AppButton(
                        label: 'Suivant',
                        borderRadius: 31,
                        onPressed: _onSuivantePressed,
                      ),
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
