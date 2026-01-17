import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/gradient_background.dart';
import '../widgets/vault_button.dart';
import '../widgets/vault_outline_button.dart';

class VaultOnboardingScreen extends StatelessWidget {
  const VaultOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    const primaryColor = Color(0xFF13b6ec);
    const backgroundDark = Color(0xFF101d22);

    return Scaffold(
      backgroundColor: backgroundDark,
      body: Stack(
        children: [
          const GradientBackground(),
          Positioned.fill(
            child: CustomPaint(
              painter: GridPainter(
                color: Colors.white.withOpacity(0.05),
                spacing: 40.0,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text(
                        'VAULT',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -1.0,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        '.',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: size.width * 0.8,
                          height: size.width * 0.8,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: primaryColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                              ),
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                              ),
                              Transform.rotate(
                                angle: 0.785,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: primaryColor.withOpacity(0.5),
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.lock_outline,
                                size: 48,
                                color: primaryColor.withOpacity(0.8),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Secure Your Legacy',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Password-based encryption with PBKDF2. Your master password derives the encryption key.',
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            color: Colors.grey[400],
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  VaultButton(
                    text: 'Create New Vault',
                    icon: const Icon(Icons.add_circle_outline),
                    onTap: () {
                      Navigator.pushNamed(context, '/set-master-password');
                    },
                    backgroundColor: primaryColor,
                    textColor: backgroundDark,
                  ),
                  const SizedBox(height: 16),
                  VaultOutlineButton(
                    text: 'Import Recovery Phrase',
                    icon: Icons.history,
                    onTap: () {
                      // Import flow
                    },
                    textColor: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  Column(
                    children: [
                      Text(
                        'YOUR KEYS, YOUR CRYPTO.',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: Colors.grey[600],
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'v1.0.2 • Master Password Encrypted',
                        style: GoogleFonts.notoSans(
                          fontSize: 10,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  final double spacing;

  GridPainter({required this.color, required this.spacing});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
