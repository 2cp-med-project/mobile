import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../config/app_colors.dart';

class HealioLogo extends StatelessWidget {
  const HealioLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset('assets/images/logo.svg', height: 78, width: 56),
        const SizedBox(height: 6),
        Text(
          'Healio',
          style: TextStyle(
            color: const Color(0xFF1FAF87),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
