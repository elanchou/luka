import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class SaultOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? borderColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final bool isFullWidth;

  const SaultOutlineButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
    this.borderColor,
    this.textColor,
    this.width,
    this.height = 56.0,
    this.borderRadius = 12.0,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color brColor = borderColor ?? AppColors.softBorderColor;
    final Color txtColor = textColor ?? AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        hoverColor: Colors.white.withValues(alpha: 0.02),
        child: Container(
          width: isFullWidth ? double.infinity : width,
          height: height,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.025),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: brColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.textSecondary, size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: txtColor,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
