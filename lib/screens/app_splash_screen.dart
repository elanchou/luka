import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/vault_provider.dart';
import '../services/vault_service.dart';
import '../services/master_key_service.dart';

class AppSplashScreen extends StatefulWidget {
  const AppSplashScreen({super.key});

  @override
  State<AppSplashScreen> createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<AppSplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    _checkVaultStatus();
  }


  Future<void> _checkVaultStatus() async {
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    try {
      final masterKeyService = MasterKeyService();
      final hasPassword = await masterKeyService.hasPassword();

      if (mounted) {
        if (hasPassword) {
          // 已经设置过密码 -> 直接进入密码输入页
          Navigator.pushReplacementNamed(context, '/master-password-input');
        } else {
          // 没有设置密码 -> 进入欢迎页
          Navigator.pushReplacementNamed(context, '/onboarding');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Subtle gradient background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Colors.white.withOpacity(0.05),
                    Colors.transparent,
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with animations
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow effect
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF1990e6).withOpacity(0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        // Geometric logo
                        CustomPaint(
                          size: const Size(80, 80),
                          painter: VaultLogoPainter(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 64),

                // Title
                FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'VAULT',
                        style: TextStyle(
                          color: const Color(0xFFe0e0e0),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 14.4,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'SECURE STORAGE',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Loading indicator at bottom
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
                ),
              ),
              child: Center(
                child: SizedBox(
                  width: 48,
                  height: 1,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              const Color(0xFF333333),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(seconds: 4),
                        curve: Curves.easeInOut,
                        builder: (context, value, child) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  const Color(0xFF1990e6).withOpacity(0.5),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VaultLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);

    // Draw rotated square (diamond shape)
    final squareSize = 31.0;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(0.785398); // 45 degrees
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: squareSize, height: squareSize),
        const Radius.circular(2),
      ),
      paint,
    );
    canvas.restore();

    // Draw center circle
    canvas.drawCircle(center, 8, paint);

    // Draw lines from circle
    canvas.drawLine(
      Offset(center.dx, center.dy - 8),
      Offset(center.dx, center.dy - 16),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy + 8),
      Offset(center.dx, center.dy + 16),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - 8, center.dy),
      Offset(center.dx - 16, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + 8, center.dy),
      Offset(center.dx + 16, center.dy),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
