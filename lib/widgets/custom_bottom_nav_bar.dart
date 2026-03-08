import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:ui';
import '../utils/constants.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.84),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: AppColors.softBorderColor,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 36,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 72,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavBarItem(
                    icon: PhosphorIconsBold.gridFour,
                    label: 'Vault',
                    isSelected: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                  _NavBarItem(
                    icon: PhosphorIconsBold.clockCounterClockwise,
                    label: 'Activity',
                    isSelected: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),
                  _NavBarItem(
                    icon: PhosphorIconsBold.gear,
                    label: 'Settings',
                    isSelected: currentIndex == 2,
                    onTap: () => onTap(2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryColor.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryColor.withValues(alpha: 0.22)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color:
                      isSelected ? AppColors.primaryColor : AppColors.textMuted,
                  size: 18,
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
