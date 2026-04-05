// widgets/app_text_field.dart
import 'package:flutter/material.dart';
import 'package:mobile/config/app_colors.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String                 hint;
  final bool                   obscureText;
  final TextInputType          keyboardType;
  final String?                errorText;
  final ValueChanged<String>?  onChanged;
  final Widget?                suffixIcon;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.obscureText  = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.onChanged,
    this.suffixIcon,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;

    // Label colour:
    // - error   → red   (always)
    // - focused → primary green
    // - resting → grey  (even if field has text)
    final labelColor = hasError
        ? AppColors.error
        : _focused
            ? AppColors.primary
            : AppColors.textGrey;

    // Border colour:
    // - error   → red
    // - focused → primary green
    // - resting → grey
    final borderColor = hasError
        ? AppColors.error
        : _focused
            ? AppColors.primary
            : AppColors.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller:   widget.controller,
          focusNode:    _focusNode,
          obscureText:  widget.obscureText,
          keyboardType: widget.keyboardType,
          onChanged:    widget.onChanged,
          style: const TextStyle(fontSize: 14, color: AppColors.textDark),
          decoration: InputDecoration(
            labelText: widget.hint,
            // Same color for both floating and non-floating states
            // so it turns grey again when unfocused
            labelStyle: TextStyle(color: labelColor, fontSize: 13),
            floatingLabelStyle: TextStyle(color: labelColor, fontSize: 12),
            floatingLabelBehavior: FloatingLabelBehavior.auto,

            suffixIcon: hasError
                ? const Icon(Icons.warning_amber_rounded,
                    color: AppColors.error, size: 20)
                : widget.suffixIcon,

            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor, width: 1.5),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              widget.errorText!,
              style: const TextStyle(color: AppColors.error, fontSize: 11),
            ),
          ),
        ],
      ],
    );
  }
}