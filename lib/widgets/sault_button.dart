import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class SaultButton extends StatelessWidget {
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

  const SaultButton({
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
    final Color bgColor = backgroundColor ?? AppColors.primaryColor;
    final Color txtColor = textColor ?? AppColors.backgroundDark;
    final isDisabled = onTap == null;

    final Widget buttonContent = isLoading
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
                  text,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: txtColor,
                    letterSpacing: 0.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                (isDisabled ? bgColor.withValues(alpha: 0.45) : bgColor),
                (isDisabled ? bgColor.withValues(alpha: 0.34) : bgColor.withValues(alpha: 0.86)),
              ],
            ),
            border: Border.all(
              color: isDisabled
                  ? bgColor.withValues(alpha: 0.10)
                  : bgColor.withValues(alpha: 0.35),
            ),
            boxShadow: [
              if (!isDisabled)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
            ],
          ),
          child: buttonContent,
        ),
      ),
    );
  }
}
