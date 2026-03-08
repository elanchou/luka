import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class SaultTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? placeholder;
  final String? hintText;
  final IconData? suffixIcon;
  final bool obscureText;
  final bool? isPassword;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const SaultTextField({
    super.key,
    required this.controller,
    this.label,
    this.placeholder,
    this.hintText,
    this.suffixIcon,
    this.obscureText = false,
    this.isPassword,
    this.textInputAction,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Support both naming conventions
    final bool shouldObscure = isPassword ?? obscureText;
    final String? displayHint = hintText ?? placeholder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
        ],
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.backgroundElevated,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.softBorderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: shouldObscure,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            onChanged: onChanged,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: displayHint,
              hintStyle: GoogleFonts.notoSans(
                color: AppColors.textMuted,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              border: InputBorder.none,
              suffixIcon: suffixIcon != null
                  ? Icon(suffixIcon, color: AppColors.textMuted, size: 18)
                  : null,
            ),
            cursorColor: AppColors.primaryColor,
          ),
        ),
      ],
    );
  }
}
