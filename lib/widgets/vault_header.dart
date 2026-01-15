import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VaultHeader extends StatelessWidget {
  final String title;
  final bool showUserIcon;

  const VaultHeader({
    super.key,
    this.title = 'VAULT',
    this.showUserIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 4.0,
          ),
        ),
        if (showUserIcon)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 20,
            ),
          ),
      ],
    );
  }
}
