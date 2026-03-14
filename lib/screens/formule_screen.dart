// screens/formule_screen.dart
// After OTP verification — medical form intro screen

import 'package:flutter/material.dart';
import '../widgets/healio_logo.dart';
import '../widgets/signup_bubbles.dart';
import '../widgets/app_button.dart';
import '../config/app_colors.dart';
import 'medical_form_screen.dart';


class FormuleScreen extends StatelessWidget {
  const FormuleScreen({super.key});

  // medical form items with icons
  static const _items = [
    (Icons.water_drop_outlined, 'Groupe sanguin', 'Choisissez une réponse'),
    (Icons.eco_outlined, 'Allergies', 'Citez-les toutes'),
    (Icons.monitor_heart_outlined, 'Maladies chroniques', 'Citez-les toutes'),
    (
      Icons.medical_services_outlined,
      'Antécédents chirurgicaux',
      'Si oui, citez-les',
    ),
    (Icons.medication_outlined, 'Médicaments actuels', 'Si oui, citez-les'),
  ];

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
                  const SizedBox(height: 30),

                  const HealioLogo(),

                  const SizedBox(height: 20),

                  // white card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // APRÈS INSCRIPTION tag
                        Row(
                          children: [
                            Icon(
                              Icons.arrow_forward,
                              color: AppColors.primary,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'APRÈS INSCRIPTION',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // title — mixed colors
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              height: 1.3,
                            ),
                            children: [
                              TextSpan(
                                text: 'Votre dossier\n',
                                style: TextStyle(color: Colors.black87),
                              ),
                              TextSpan(
                                text: 'médical\n',
                                style: TextStyle(color: Color(0xFF1FAF87)),
                              ),
                              TextSpan(
                                text: 'personnalisé',
                                style: TextStyle(color: Colors.black87),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // subtitle
                        const Text(
                          'Ce formulaire recueille vos informations médicales pour un suivi précis et personnalisé.\nVeuillez renseigner les informations ci-dessous :',
                          style: TextStyle(
                            color: Colors.black45,
                            fontSize: 11,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // divider
                        Divider(color: Colors.grey.shade200, height: 1),

                        const SizedBox(height: 12),

                        // medical items list
                        ..._items.map(
                          (item) => _MedicalItem(
                            icon: item.$1,
                            title: item.$2,
                            subtitle: item.$3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // commencer button
                  AppButton(
                    label: 'Commencer  >',
                    borderRadius: 14,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MedicalFormScreen(),
                        ),
                      );
                    },
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

// single medical item row
class _MedicalItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MedicalItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // icon in teal circle
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE8FAF5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF1FAF87), size: 18),
          ),
          const SizedBox(width: 14),
          // title + subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.black45, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
