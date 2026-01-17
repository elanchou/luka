import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VaultTextField extends StatelessWidget {
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

  const VaultTextField({
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
    const primaryColor = Color(0xFF13b6ec);
    const labelColor = Color(0xFF5f747a);
    const inputBorderColor = Color(0xFF283539);

    // Support both naming conventions
    final bool shouldObscure = isPassword ?? obscureText;
    final String? displayHint = hintText ?? placeholder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!.toUpperCase(),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: labelColor,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          obscureText: shouldObscure,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.normal,
          ),
          decoration: InputDecoration(
            hintText: displayHint,
            hintStyle: GoogleFonts.spaceGrotesk(
              color: inputBorderColor,
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: inputBorderColor),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: inputBorderColor)
                : null,
          ),
          cursorColor: primaryColor,
        ),
      ],
    );
  }
}
