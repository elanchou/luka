import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VaultBrand extends StatelessWidget {
  final double fontSize;
  final MainAxisAlignment mainAxisAlignment;

  const VaultBrand({
    super.key,
    this.fontSize = 24.0,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF13b6ec);

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'VAULT',
          style: GoogleFonts.spaceGrotesk(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -1.0,
            height: 1.0,
          ),
        ),
        Text(
          '.',
          style: GoogleFonts.spaceGrotesk(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: primaryColor,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}
