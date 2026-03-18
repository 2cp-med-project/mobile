import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../config/app_colors.dart';

class TopBubbles extends StatelessWidget {
  const TopBubbles({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Container(color: AppColors.primaryLight),

        Positioned(
          top: 0,
          left: 0,
          child: SvgPicture.asset(
            'assets/images/loginIcon.svg',
            width: w * 0.24,
            height: h * 0.20, 
            fit: BoxFit.fill,
          ),
        ),

        Positioned(
          top: h * 0.30,
          right: -50,
          child: SvgPicture.asset(
            'assets/images/loginIcon2.svg',
            width: w * 0.35,
            height: h * 0.25,
            fit: BoxFit.fill,
          ),
        ),

        Positioned(
          top: h * 0.45,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(130),
                topRight: Radius.circular(130),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
