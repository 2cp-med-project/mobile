// widgets/app_button.dart
// Primary teal button with built-in loading state + optional custom border radius

import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class AppButton extends StatelessWidget {
  final String        label;
  final bool          isLoading;
  final VoidCallback? onPressed;
  final double        borderRadius;  // default 8, pass 31 for pill shape

  const AppButton({
    super.key,
    required this.label,
    this.isLoading    = false,
    this.onPressed,
    this.borderRadius = 8,           // default — same as before
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width:  double.infinity,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.55),
              AppColors.primary.withValues(alpha: 0.85),
            ],
            begin: Alignment.centerLeft,
            end:   Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(borderRadius), 
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2,
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color:      Colors.white,
                    fontSize:   15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}