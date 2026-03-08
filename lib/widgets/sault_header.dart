import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../utils/constants.dart';
import 'sault_brand.dart';

class SaultHeader extends StatelessWidget {
  final String? title;
  final bool showUserIcon;

  const SaultHeader({
    super.key,
    this.title,
    this.showUserIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title == null || title == 'SAULT')
                const SaultBrand(fontSize: 20)
              else
                Text(
                  title!,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
              const SizedBox(height: 6),
              Text(
                'Private access only',
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        if (showUserIcon)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white.withValues(alpha: 0.04),
              border: Border.all(
                color: AppColors.softBorderColor,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              PhosphorIconsBold.user,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ),
      ],
    );
  }
}
