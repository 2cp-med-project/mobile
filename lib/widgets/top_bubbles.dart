// widgets/top_bubbles.dart
// top shape = 1/4 (logo only), green gap = 1/4 (SE CONNECTER), bottom shape = 2/4 (all content)

import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class TopBubbles extends StatelessWidget {
  const TopBubbles({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Stack(
      children: [

        // full green background — shows in the gap and on sides
        Container(color: AppColors.primaryLight),

        // top white shape — 1/4 of screen, logo sits here
        Positioned(
          top:   0,
          left:  0,
          right: 0,
          child: Container(
            height: h * 0.3,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft:  Radius.circular(130),
                bottomRight: Radius.circular(130),
              ),
            ),
          ),
        ),
        

        // bottom white shape — 2/4 of screen, all content sits here
        // starts at h * 0.50 → leaves exactly 1/4 as green gap
        Positioned(
          top:    h * 0.45,
          left:   0,
          right:  0,
          bottom: 0,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft:  Radius.circular(130),
                topRight: Radius.circular(130),
              ),
            ),
          ),
        ),

      ],
    );
  }
}