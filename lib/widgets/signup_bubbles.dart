// widgets/signup_bubbles.dart
// Background blobs for sign up screen — different layout from login

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignupBubbles extends StatelessWidget {
  const SignupBubbles({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Stack(
      children: [

        // light green full background
        Container(color: const Color(0xFFEEFBF7)),

        // top left blob
        Positioned(
          top: 0,
          left: 0,
          child: SvgPicture.asset(
            'assets/images/loginIcon.svg',
            width: w * 0.24,
            height: h * 0.20, //0.24 for bigger
            fit: BoxFit.fill,
          ),
        ),

        // top right blob
        Positioned(
          top: h * 0.20,
          right: -65,
          child: SvgPicture.asset(
            'assets/images/loginIcon2.svg',
            width: w * 0.35,
            height: h * 0.25,
            fit: BoxFit.fill,
          ),
        ),

        // bottom right blob
        Positioned(
          bottom: -30,
          right:  -40,
          child: SvgPicture.asset(
            'assets/images/loginIcon3.svg',
            width:  w * 0.65,
            height: h * 0.22,
            fit:    BoxFit.fill,
          ),
        ),

      ],
    );
  }
}