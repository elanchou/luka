import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class VaultButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final bool isFullWidth;
  final bool isLoading;

  const VaultButton({
    super.key,
    required this.text,
    this.onTap,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56.0,
    this.borderRadius = 12.0,
    this.isFullWidth = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Default colors
    const defaultPrimaryColor = Color(0xFF13b6ec);
    const defaultBackgroundDark = Color(0xFF101d22);

    final bgColor = backgroundColor ?? defaultPrimaryColor;
    final txtColor = textColor ?? defaultBackgroundDark;
    final isDisabled = onTap == null;

    Widget buttonContent = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(txtColor),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: txtColor, size: 20),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  text.toUpperCase(),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: txtColor,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    return Material(
      color: isDisabled
          ? bgColor.withValues(alpha: 0.3)
          : bgColor,
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: Clip.antiAlias,
      elevation: isDisabled ? 0 : 4,
      shadowColor: bgColor.withValues(alpha: 0.25),
      child: InkWell(
        onTap: isLoading || isDisabled ? null : () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        child: Container(
          width: isFullWidth ? double.infinity : width,
          height: height,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: buttonContent,
        ),
      ),
    );
  }
}
