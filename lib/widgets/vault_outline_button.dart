import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VaultOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? borderColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final bool isFullWidth;

  const VaultOutlineButton({
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
    // Default colors
    final defaultBorderColor = Colors.white.withOpacity(0.2);
    const defaultTextColor = Colors.white;

    final brColor = borderColor ?? defaultBorderColor;
    final txtColor = textColor ?? defaultTextColor;

    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(color: brColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        hoverColor: Colors.white.withOpacity(0.05),
        child: Container(
          width: isFullWidth ? double.infinity : width,
          height: height,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: txtColor.withOpacity(0.6), size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                text.toUpperCase(),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: txtColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
