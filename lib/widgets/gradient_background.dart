import 'package:flutter/material.dart';
import '../utils/constants.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.backgroundDark,
                  AppColors.backgroundElevated,
                  AppColors.backgroundDark,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -90,
          right: -40,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryColor.withValues(alpha: 0.10),
                  AppColors.primaryColor.withValues(alpha: 0.02),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.06),
                  blurRadius: 120,
                  spreadRadius: 18,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: -110,
          left: -60,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.06),
                  Colors.white.withValues(alpha: 0.01),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.03),
                  blurRadius: 100,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.015),
                  Colors.transparent,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.28, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
