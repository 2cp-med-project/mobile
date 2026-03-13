import 'package:flutter/material.dart';
import 'package:mobile/config/app_colors.dart';
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String                 hint;
  final bool                   obscureText;
  final TextInputType          keyboardType;
  final String?                errorText;
  final ValueChanged<String>?  onChanged;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.obscureText  = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller:   controller,
          obscureText:  obscureText,
          keyboardType: keyboardType,
          onChanged:    onChanged,
          style: const TextStyle(fontSize: 14, color: AppColors.textDark),
          decoration: InputDecoration(
            hintText:  hint,
            hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 13),
            labelText: hasError ? hint : null,
            labelStyle: const TextStyle(color: AppColors.primary, fontSize: 12),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            suffixIcon: hasError
                ? const Icon(Icons.warning_amber_rounded, color: AppColors.error , size: 20)
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: hasError ? AppColors.error : AppColors.border, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: hasError ? AppColors.error : AppColors.primary , width: 1.5),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(errorText!, style: const TextStyle(color: AppColors.error, fontSize: 11)),
          ),
        ],
      ],
    );
  }
}