// widgets/top_bubbles.dart
// Decorative teal circles at the top of the screen — used on sign_in and sign_up

import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class TopBubbles extends StatelessWidget {
  const TopBubbles({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Stack(
        children: [
          _bubble(size: w * 0.55, top: -55, right: -35, opacity: 0.45),
          _bubble(size: w * 0.48, top: -75, left: -45, opacity: 0.30),
          _bubble(size: w * 0.28, top: 18, left: w * 0.28, opacity: 0.35),
        ],
      ),
    );
  }

  Widget _bubble({
    required double size,
    required double opacity,
    double? top,
    double? left,
    double? right,
  }) => Positioned(
    top: top,
    left: left,
    right: right,
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withOpacity(opacity),
      ),
    ),
  );
}
