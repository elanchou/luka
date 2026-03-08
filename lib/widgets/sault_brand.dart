import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class SaultBrand extends StatelessWidget {
  final double fontSize;
  final MainAxisAlignment mainAxisAlignment;

  const SaultBrand({
    super.key,
    this.fontSize = 24.0,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'SAULT',
          style: GoogleFonts.spaceGrotesk(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: fontSize >= 30 ? 3.0 : 2.2,
            height: 1.0,
          ),
        ),
        Container(
          width: fontSize * 0.14,
          height: fontSize * 0.14,
          margin: EdgeInsets.only(left: fontSize * 0.18, top: fontSize * 0.08),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(fontSize),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        Text(
          'vault',
          style: GoogleFonts.spaceGrotesk(
            fontSize: fontSize * 0.28,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
            letterSpacing: 1.8,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}
