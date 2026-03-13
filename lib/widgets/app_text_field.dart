// widgets/app_text_field.dart
// Reusable input field — matches Figma exactly:
// normal: grey label inside field
// focused: label floats on top border
// error: red border + red label + warning icon + error text below

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

            // label acts as hint when not focused (grey inside)
            // floats to top border when focused
            labelText: hint,
            labelStyle: TextStyle(
              color:    hasError ? AppColors.error : AppColors.textGrey,
              fontSize: 13,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto,

            // warning icon only on error
            suffixIcon: hasError
                ? const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20)
                : null,

            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

            // normal state — grey border
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.border,
                width: 1.2,
              ),
            ),
            // focused state — teal border
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),

        // error message below field
        if (hasError) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              errorText!,
              style: const TextStyle(color: AppColors.error, fontSize: 11),
            ),
          ),
        ],
      ],
    );
  }
}