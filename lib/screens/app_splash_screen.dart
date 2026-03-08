import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/master_key_service.dart';
import '../utils/constants.dart';
import '../widgets/gradient_background.dart';
import '../widgets/sault_brand.dart';

class AppSplashScreen extends StatefulWidget {
  const AppSplashScreen({super.key});

  @override
  State<AppSplashScreen> createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<AppSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<double>(begin: 18, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _checkVaultStatus();
  }

  Future<void> _checkVaultStatus() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    try {
      final MasterKeyService masterKeyService = MasterKeyService();
      final bool hasPassword = await masterKeyService.hasPassword();
      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        hasPassword ? '/master-password-input' : '/onboarding',
      );
    } catch (_) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: AnimatedBuilder(
                  animation: _slideAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: child,
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white.withValues(alpha: 0.04),
                          border: Border.all(color: AppColors.softBorderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.22),
                              blurRadius: 36,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.primaryColor,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const SaultBrand(fontSize: 28, mainAxisAlignment: MainAxisAlignment.center),
                      const SizedBox(height: 12),
                      Text(
                        'Private storage for sensitive assets',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 64),
                      SizedBox(
                        width: 120,
                        child: Column(
                          children: [
                            Container(
                              height: 2,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: Colors.white.withValues(alpha: 0.06),
                              ),
                              child: FractionallySizedBox(
                                widthFactor: 0.6,
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Preparing vault',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
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
