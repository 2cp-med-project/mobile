// screens/welcome_screen.dart
// Shown after medical form is submitted — account created successfully
// loads prenom from local storage (StorageHelper)

import 'package:flutter/material.dart';
import '../widgets/healio_logo.dart';
import '../widgets/signup_bubbles.dart';
import '../widgets/app_button.dart';
import '../config/app_colors.dart';
import '../config/storage_helper.dart';
import 'main_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String _prenom = '';

  @override
  void initState() {
    super.initState();
    _loadPrenom();
  }

  // loads prenom from local storage
  Future<void> _loadPrenom() async {
    final prenom = await StorageHelper.getPrenom();
    setState(() => _prenom = prenom ?? '');
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
                  const SizedBox(height: 40),

                  const HealioLogo(),

                  const SizedBox(height: 26),

                  // teal checkmark box
                  Container(
                    width:  64,
                    height: 64,
                    decoration: BoxDecoration(
                      color:        AppColors.primary.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 36),
                  ),

                  const SizedBox(height: 26),

                  // white card — flat, no shadow
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color:        Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // COMPTE ACTIF tag
                        Row(
                          children: [
                            Icon(Icons.circle, color: AppColors.primary, size: 8),
                            const SizedBox(width: 4),
                            Text(
                              'COMPTE ACTIF',
                              style: TextStyle(
                                color:         AppColors.primary,
                                fontSize:      10,
                                fontWeight:    FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // welcome title — uses _prenom from local storage
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize:   22,
                              fontWeight: FontWeight.w800,
                              height:     1.3,
                            ),
                            children: [
                              const TextSpan(
                                text:  'Bienvenue,\n',
                                style: TextStyle(color: Colors.black87),
                              ),
                              TextSpan(
                                text:  '$_prenom...',
                                style: TextStyle(color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // description
                        const Text(
                          'Votre dossier médical a été créé avec succès. Vous pouvez maintenant accéder à toutes les fonctionnalités de HEALIO.',
                          style: TextStyle(
                            color:    Colors.black45,
                            fontSize: 12,
                            height:   1.6,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // feature list
                        _featureItem(
                          Icons.description_outlined,
                          'Consultez votre dossier médical partout',
                          'Accédez à vos informations de santé à tout moment.',
                        ),
                        const SizedBox(height: 14),
                        _featureItem(
                          Icons.warning_amber_outlined,
                          'Vos informations en cas d\'urgence',
                          'Les médecins et les secours peuvent accéder rapidement aux données nécessaires.',
                        ),
                        const SizedBox(height: 14),
                        _featureItem(
                          Icons.chat_bubble_outline,
                          'Chatbot et meilleurs médecins',
                          'Discutez avec le chatbot et découvrez les médecins les mieux notés par les patients.',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // accéder button
                  AppButton(
                    label:        'Accéder à l\'application >',
                    borderRadius: 14,
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const MainScreen()),
                        (route) => false,
                      );
                    },
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureItem(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34, height: 34,
          decoration: const BoxDecoration(
            color: Color(0xFFE8FAF5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize:   12,
                  fontWeight: FontWeight.w700,
                  color:      Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color:    Colors.black45,
                  height:   1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}