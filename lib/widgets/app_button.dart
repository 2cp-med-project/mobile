// app_button.dart
import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class AppButton extends StatelessWidget {
  final String        label;
  final bool          isLoading;
  final VoidCallback? onPressed;

  const AppButton({
    super.key,
    required this.label,
    this.isLoading = false,
    this.onPressed,
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
              AppColors.primary.withValues(alpha: 0.55), // left
              AppColors.primary.withValues(alpha: 0.80), // right
            ],
            begin: Alignment.centerLeft,
            end:   Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(8),
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